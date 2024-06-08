module hittable;
@safe @nogc nothrow:

import ray;
import vec3;

struct HitRecord
{
    Point3f p;
    Vec3f normal;
    float t;
    bool isFront;

    void setFaceNormal(const Ray ray, Vec3f outNormal)
    {
        isFront = ray.direction.dot(outNormal) < 0;
        normal = isFront ? outNormal : -outNormal;
    }
}

interface Hittable
{
    bool hit(const Ray ray, float rayTmin, float rayTmax, out HitRecord rec) const;
}
