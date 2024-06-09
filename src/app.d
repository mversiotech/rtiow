import camera;
import color;
import hittable;
import material;
import sphere;
import vec3;

enum
{
    imageWidth = 400,
    imageHeight = 225
}

void main()
{
    import std.math : PI_2;

    auto scene = new HittableList();

    const groundMaterial = new Lambertian(Color(0.8f, 0.8f, 0.0f));
    const centerMaterial = new Lambertian(Color(0.1f, 0.2f, 0.5f));
    const leftMaterial = new Dielectric(1.5f);
    const bubbleMaterial = new Dielectric(1.0f / 1.5f);
    const rightMaterial = new Metal(Color(0.8f, 0.6f, 0.2f), 1.0f);

    scene.add(new Sphere(Point3f(0.0f, -100.5f, -1.0f), 100.0f, groundMaterial));
    scene.add(new Sphere(Point3f(0.0f, 0.0f, -1.2f), 0.5f, centerMaterial));
    scene.add(new Sphere(Point3f(-1.0f, 0.0f, -1.0f), 0.5f, leftMaterial));
    scene.add(new Sphere(Point3f(-1.0f, 0.0f, -1.0f), 0.4f, bubbleMaterial));
    scene.add(new Sphere(Point3f(1.0f, 0.0f, -1.0f), 0.5f, rightMaterial));

    const camPos = Point3f(-2, 2, 1);
    const camLookAt = Point3f(0, 0, -1);
    const camUp = Vec3f(0, 1, 0);
    const camVFov = PI_2;

    const camera = new Camera(camPos, camLookAt, camUp, camVFov);

    auto target = new ColorBuffer(imageWidth, imageHeight);

    camera.render(target, scene);
    target.savePNG("renderings/distant.png");
}
