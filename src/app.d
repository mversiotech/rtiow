import camera;
import color;
import hittable;
import sphere;
import vec3;

enum
{
    imageWidth = 400,
    imageHeight = 225
}

void main()
{
    const camera = new Camera(Point3f(0, 0, 0));

    auto scene = new HittableList();
    scene.add(new Sphere(Point3f(0, 0, -1), 0.5));
    scene.add(new Sphere(Point3f(0, -100.5, -1), 100));

    auto target = new ColorBuffer(imageWidth, imageHeight);

    camera.render(target, scene);
    target.savePNG("output.png");
}
