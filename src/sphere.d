module sphere;
@safe nothrow:

import hittable;
import interval;
import ray;
import vec3;

class Sphere : Hittable
{
    const Point3f center;
    const float radius;

    this(Point3f center, float radius)
    {
        assert(radius > 0);
        this.center = center;
        this.radius = radius;
    }

    HitRecord hit(const Ray ray, Interval rayT) const
    {
        import std.math : sqrt;

        Vec3f oc = center - ray.origin;
        float a = ray.direction.lengthSquared();
        float h = ray.direction.dot(oc);
        float c = oc.lengthSquared() - radius * radius;
        float discriminant = h * h - a * c;

        if (discriminant < 0)
            return null;

        float sqrtd = sqrt(discriminant);

        float root = (h - sqrtd) / a;
        if (root <= rayT.min || root >= rayT.max)
        {
            root = (h + sqrtd) / a;
            if (root <= rayT.min || root >= rayT.max)
                return null;
        }

        Vec3f p = ray.at(root);
        Vec3f outNormal = (p - center) / radius;
        auto rec = new HitRecord(ray, p, outNormal, root);

        return rec;
    }
}
