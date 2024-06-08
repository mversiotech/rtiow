import std.stdio;

import color;
import ray;
import vec3;

enum
{
    imageWidth = 400,
    imageHeight = 225
}

void main()
{
    // Camera parameters
    const aspectRatio = cast(float) imageWidth / cast(float) imageHeight;
    const focalLength = 1.0f;
    const viewportHeight = 2.0f;
    const viewportWidth = viewportHeight * aspectRatio;
    const cameraCenter = Point3f(0, 0, 0);

    // vectors across the horizontal and vertical viewport edges
    const viewportU = Vec3f(viewportWidth, 0, 0);
    const viewportV = Vec3f(0, -viewportHeight, 0);

    // horizontal and vertical delta vectors from pixel to pixel
    const pixelDeltaU = viewportU / imageWidth;
    const pixelDeltaV = viewportV / imageHeight;

    // location of the upper left pixel
    const viewportUpperLeft = cameraCenter - Vec3f(0, 0,
            focalLength) - viewportU * 0.5f - viewportV * 0.5f;
    const firstPixelLoc = viewportUpperLeft + 0.5f * (pixelDeltaU + pixelDeltaV);

    auto buffer = new ColorBuffer(imageWidth, imageHeight);

    for (int y = 0; y < imageHeight; y++)
    {
        for (int x = 0; x < imageWidth; x++)
        {
            const pixelCenter = firstPixelLoc + (x * pixelDeltaU) + (y * pixelDeltaV);
            const rayDir = pixelCenter - cameraCenter;
            const ray = new Ray(cameraCenter, rayDir);

            const pixelColor = rayColor(ray);
            buffer.setPixel(x, y, pixelColor);
        }
    }

    buffer.savePNG("output.png");
}

Color rayColor(const Ray ray)
{
    const sphereCenter = Point3f(0, 0, -1);
    const t = hitSphere(sphereCenter, 0.5f, ray);
    if (t > 0)
    {
        Vec3f n = (ray.at(t) - sphereCenter).unit();
        return 0.5f * Color(n.x + 1, n.y + 1, n.z + 1);
    }

    const unitDir = ray.direction.unit();
    const a = 0.5f * (unitDir.y + 1.0f);
    return (1.0f - a) * Color(1.0f, 1.0f, 1.0f) + a * Color(0.5f, 0.7f, 1.0f);
}

float hitSphere(Point3f center, float radius, const Ray ray)
{
    import std.math : sqrt;

    Vec3f oc = center - ray.origin;
    float a = ray.direction.lengthSquared();
    float h = ray.direction.dot(oc);
    float c = oc.lengthSquared() - radius * radius;
    float discriminant = h * h - a * c;

    if (discriminant < 0)
        return -1.0f;

    return (h - sqrt(discriminant)) / a;
}
