import camera;
import color;
import hittable;
import material;
import random;
import sphere;
import vec3;

enum
{
    imageWidth = 1280,
    imageHeight = 720
}

void main()
{
    import std.random : uniform01;

    auto scene = new HittableList();

    const groundMaterial = new Lambertian(Color(0.5f, 0.5f, 0.5f));
    scene.add(new Sphere(Point3f(0.0f, -1000.0f, 0.0f), 1000.0f, groundMaterial));

    for (int i = -11; i < 11; i++)
    {
        for (int j = -11; j < 11; j++)
        {
            float chooseMat = uniform01();
            const center = Point3f(i + 0.9f * uniform01(), 0.2f, j + 0.9f * uniform01());

            if ((center - Point3f(4.0f, 0.2f, 0.0f)).length() < 0.9f)
                continue;

            if (chooseMat < 0.8f)
            {
                // diffuse material
                const albedo = randomVec3f(0, 1).componentMul(randomVec3f(0, 1));
                scene.add(new Sphere(center, 0.2, new Lambertian(albedo)));
            }
            else if (chooseMat < 0.95f)
            {
                // metal material
                const albedo = randomVec3f(0.5f, 1.0f);
                auto fuzz = uniform01() * 0.5f;
                scene.add(new Sphere(center, 0.2f, new Metal(albedo, fuzz)));
            }
            else
            {
                // glass material
                scene.add(new Sphere(center, 0.2f, new Dielectric(1.5f)));
            }
        }
    }

    scene.add(new Sphere(Point3f(0, 1, 0), 1.0f, new Dielectric(1.5f)));
    scene.add(new Sphere(Point3f(-4, 1, 0), 1.0f, new Lambertian(Color(0.4f, 0.2f, 0.1f))));
    scene.add(new Sphere(Point3f(4, 1, 0), 1.0f, new Metal(Color(0.7f, 0.6f, 0.5f), 0)));

    const camPos = Point3f(13, 2, 3);
    const camLookAt = Point3f(0, 0, 0);
    const camUp = Vec3f(0, 1, 0);
    const camVFov = degreesToRadians(20.0f);
    const camDefocusAngle = degreesToRadians(0.6f);
    const camFocusDist = 10.0f;

    const camera = new Camera(camPos, camLookAt, camUp, camVFov, camDefocusAngle, camFocusDist);

    auto target = new ColorBuffer(imageWidth, imageHeight);

    camera.render(target, scene);
    target.savePNG("renderings/final.png");
}

private float degreesToRadians(float x)
{
    import std.math : PI;

    return x * PI / 180.0f;
}
