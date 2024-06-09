module camera;
nothrow:

import color;
import hittable;
import interval;
import random;
import ray;
import vec3;

// Some render parameters
enum
{
    samplesPerPixel = 500,
    maxRecursionDepth = 50
}

private struct ImageGeometry
{
    Point3f firstPixelLoc;
    Vec3f pixelDeltaU;
    Vec3f pixelDeltaV;
}

class Camera
{
    private Point3f position;
    private Vec3f right;
    private Vec3f up;
    private Vec3f back;
    private Vec3f defocusDiskU;
    private Vec3f defocusDiskV;
    private float vfov;
    private float focusDist;
    private float defocusAngle;

    this(Point3f position, Point3f lookAt, Vec3f up, float vfov, float defocusAngle, float focusDist)
    {
        import std.math : tan;

        assert(focusDist > 0);

        this.position = position;
        this.vfov = vfov;
        this.focusDist = focusDist;
        this.defocusAngle = defocusAngle;

        back = (position - lookAt).unit();
        right = up.cross(back).unit();
        this.up = back.cross(right);

        float defocusRadius = focusDist * tan(defocusAngle * 0.5f);
        defocusDiskU = right * defocusRadius;
        defocusDiskV = up * defocusRadius;
    }

    void render(ColorBuffer target, const Hittable scene) const
    {
        import std.parallelism : parallel;
        import std.range : iota;

        ImageGeometry igeom;
        setupImageGeometry(target, igeom);

        const float colorScale = 1.0f / samplesPerPixel;

        foreach (y; parallel(iota(target.h))) // render multiple scan lines in parallel
        {
            foreach (x; 0 .. target.w)
            {
                auto pixelColor = Color(0, 0, 0);

                for (int i = 0; i < samplesPerPixel; i++)
                {
                    const ray = getRay(igeom, x, y);
                    pixelColor += rayColor(ray, scene, 0);
                }

                pixelColor *= colorScale;
                target.setPixel(x, y, pixelColor);
            }
        }
    }

    private void setupImageGeometry(const ColorBuffer target, out ImageGeometry igeom) const
    {
        import std.math : tan;

        // Camera parameters
        const aspectRatio = cast(float) target.w / cast(float) target.h;
        const viewportHeight = 2.0f * tan(vfov * 0.5f) * focusDist;
        const viewportWidth = viewportHeight * aspectRatio;

        // vectors across the horizontal and vertical viewport edges
        const viewportU = viewportWidth * right;
        const viewportV = -viewportHeight * up;

        // horizontal and vertical delta vectors from pixel to pixel
        igeom.pixelDeltaU = viewportU / target.w;
        igeom.pixelDeltaV = viewportV / target.h;

        // location of the upper left pixel
        // dfmt off
        const viewportUpperLeft = position
            - focusDist * back
            - viewportU * 0.5f
            - viewportV * 0.5f;
        // dfmt on

        igeom.firstPixelLoc = viewportUpperLeft + 0.5f * (igeom.pixelDeltaU + igeom.pixelDeltaV);
    }

    /// Constructs a camera ray originating from the origin and directed at
    /// a randomly sampled point araund the pixel location (x, y).
    private Ray getRay(ref const(ImageGeometry) igeom, int x, int y) const
    {
        import std.random : uniform01;

        float offsetX = uniform01() - 0.5f;
        float offsetY = uniform01() - 0.5f;

        // dfmt off
        Vec3f pixelSample = igeom.firstPixelLoc
            + ((x + offsetX) * igeom.pixelDeltaU)
            + ((y + offsetY) * igeom.pixelDeltaV);
        // dfmt on

        Point3f origin = (defocusAngle <= 0) ? position : defocusDiskSample();
        Vec3f direction = pixelSample - origin;

        return new Ray(origin, direction);
    }

    private Color rayColor(const Ray ray, const Hittable scene, int depth) const
    {
        if (depth >= maxRecursionDepth)
            return Color(0, 0, 0);

        HitRecord rec = scene.hit(ray, Interval(0.001f, float.infinity));
        if (rec !is null)
        {
            Color attenuation;
            Ray scattered = rec.mat.scatter(ray, rec, attenuation);
            if (scattered !is null)
                return attenuation.componentMul(rayColor(scattered, scene, depth + 1));

            return Color(0, 0, 0);
        }

        const unitDir = ray.direction.unit();
        const a = 0.5f * (unitDir.y + 1.0f);
        return (1.0f - a) * Color(1.0f, 1.0f, 1.0f) + a * Color(0.5f, 0.7f, 1.0f);
    }

    private Point3f defocusDiskSample() const
    {
        Point3f p = randomUnitDiskVec3f();
        return position + (p.x * defocusDiskU) + (p.y * defocusDiskV);
    }
}
