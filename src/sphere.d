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

    bool hit(const Ray ray, Interval rayT, out HitRecord rec) const
    {
        import std.math : sqrt;

        Vec3f oc = center - ray.origin;
        float a = ray.direction.lengthSquared();
        float h = ray.direction.dot(oc);
        float c = oc.lengthSquared() - radius * radius;
        float discriminant = h * h - a * c;

        if (discriminant < 0)
            return false;

        float sqrtd = sqrt(discriminant);

        float root = (h - sqrtd) / a;
        if (root <= rayT.min || root >= rayT.max)
        {
            root = (h + sqrtd) / a;
            if (root <= rayT.min || root >= rayT.max)
                return false;
        }

        rec.t = root;
        rec.p = ray.at(root);
        Vec3f outNormal = (rec.p - center) / radius;
        rec.setFaceNormal(ray, outNormal);

        return true;
    }
}
