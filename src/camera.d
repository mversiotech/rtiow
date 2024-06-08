module camera;
@safe nothrow:

import color;
import hittable;
import interval;
import ray;
import vec3;

enum samplesPerPixel = 10;

private struct ImageGeometry
{
    Point3f firstPixelLoc;
    Vec3f pixelDeltaU;
    Vec3f pixelDeltaV;
}

class Camera
{
    private Point3f center;

    this(Point3f center)
    {
        this.center = center;
    }

    void render(ColorBuffer target, const Hittable scene) const
    {
        ImageGeometry igeom;
        setupImageGeometry(target, igeom);

        const float colorScale = 1.0f / samplesPerPixel;

        for (int y = 0; y < target.h; y++)
        {
            for (int x = 0; x < target.w; x++)
            {
                auto pixelColor = Color(0, 0, 0);

                for (int i = 0; i < samplesPerPixel; i++)
                {
                    const ray = getRay(igeom, x, y);
                    pixelColor += rayColor(ray, scene);
                }

                pixelColor *= colorScale;
                target.setPixel(x, y, pixelColor);
            }
        }
    }

    private void setupImageGeometry(const ColorBuffer target, out ImageGeometry igeom) const
    {
        // Camera parameters
        const aspectRatio = cast(float) target.w / cast(float) target.h;
        const viewportHeight = 2.0f;
        const viewportWidth = viewportHeight * aspectRatio;

        // vectors across the horizontal and vertical viewport edges
        const viewportU = Vec3f(viewportWidth, 0, 0);
        const viewportV = Vec3f(0, -viewportHeight, 0);

        // horizontal and vertical delta vectors from pixel to pixel
        igeom.pixelDeltaU = viewportU / target.w;
        igeom.pixelDeltaV = viewportV / target.h;

        const focalLength = 1.0f;

        // location of the upper left pixel
        const viewportUpperLeft = center - Vec3f(0, 0,
                focalLength) - viewportU * 0.5f - viewportV * 0.5f;

        igeom.firstPixelLoc = viewportUpperLeft + 0.5f * (igeom.pixelDeltaU + igeom.pixelDeltaV);
    }

    /// Constructs a camera ray originating from the origin and directed at
    /// a randomly sampled point araund the pixel location (x, y).
    private Ray getRay(ref const(ImageGeometry) igeom, int x, int y) const
    {
        import std.random : uniform;

        float offsetX = uniform(-0.5f, 0.5f);
        float offsetY = uniform(-0.5f, 0.5f);

        // dfmt off
        Vec3f pixelSample = igeom.firstPixelLoc
            + ((x + offsetX) * igeom.pixelDeltaU)
            + ((y + offsetY) * igeom.pixelDeltaV);
        // dfmt on

        return new Ray(center, pixelSample - center);
    }

    private Color rayColor(const Ray ray, const Hittable scene) const
    {
        HitRecord rec;

        if (scene.hit(ray, Interval(0, float.infinity), rec))
        {
            Vec3f n = rec.normal;
            return 0.5f * Color(n.x + 1, n.y + 1, n.z + 1);
        }

        const unitDir = ray.direction.unit();
        const a = 0.5f * (unitDir.y + 1.0f);
        return (1.0f - a) * Color(1.0f, 1.0f, 1.0f) + a * Color(0.5f, 0.7f, 1.0f);
    }
}
