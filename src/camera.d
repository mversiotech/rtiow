module camera;
@safe nothrow:

import color;
import hittable;
import interval;
import ray;
import vec3;

class Camera
{
    private Point3f center;

    this(Point3f center)
    {
        this.center = center;
    }

    void render(ColorBuffer target, const Hittable scene) const
    {
        Point3f firstPixelLoc;
        Vec3f pixelDeltaU;
        Vec3f pixelDeltaV;

        setupGeometry(target, firstPixelLoc, pixelDeltaU, pixelDeltaV);

        for (int y = 0; y < target.h; y++)
        {
            for (int x = 0; x < target.w; x++)
            {
                const pixelCenter = firstPixelLoc + (x * pixelDeltaU) + (y * pixelDeltaV);
                const rayDir = pixelCenter - center;
                const ray = new Ray(center, rayDir);

                const pixelColor = rayColor(ray, scene);
                target.setPixel(x, y, pixelColor);
            }
        }
    }

    private void setupGeometry(const ColorBuffer target, out Point3f firstPixelLoc,
            out Vec3f pixelDeltaU, out Vec3f pixelDeltaV) const
    {
        // Camera parameters
        const aspectRatio = cast(float) target.w / cast(float) target.h;
        const viewportHeight = 2.0f;
        const viewportWidth = viewportHeight * aspectRatio;

        // vectors across the horizontal and vertical viewport edges
        const viewportU = Vec3f(viewportWidth, 0, 0);
        const viewportV = Vec3f(0, -viewportHeight, 0);

        // horizontal and vertical delta vectors from pixel to pixel
        pixelDeltaU = viewportU / target.w;
        pixelDeltaV = viewportV / target.h;

        const focalLength = 1.0f;

        // location of the upper left pixel
        const viewportUpperLeft = center - Vec3f(0, 0,
                focalLength) - viewportU * 0.5f - viewportV * 0.5f;

        firstPixelLoc = viewportUpperLeft + 0.5f * (pixelDeltaU + pixelDeltaV);
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
