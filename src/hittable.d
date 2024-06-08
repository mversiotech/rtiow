module hittable;
@safe nothrow:

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

class HittableList : Hittable
{
    private Hittable[] objects;

    void add(Hittable obj)
    {
        objects ~= obj;
    }

    void clear()
    {
        objects.length = 0;
    }

    bool hit(const Ray ray, float rayTmin, float rayTmax, out HitRecord rec) const
    {
        HitRecord tmpRec;
        bool haveHit;
        float closestT = rayTmax;

        foreach (obj; objects)
        {
            if (obj.hit(ray, rayTmin, closestT, tmpRec))
            {
                haveHit = true;
                closestT = tmpRec.t;
                rec = tmpRec;
            }
        }

        return haveHit;
    }
}
