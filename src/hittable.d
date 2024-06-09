module hittable;
@safe nothrow:

import interval;
import ray;
import vec3;

class HitRecord
{
    const Point3f p;
    const Vec3f normal;
    const float t;
    const bool isFront;

    this(const Ray ray, Point3f p, Vec3f outNormal, float t)
    {
        this.p = p;
        this.t = t;
        isFront = ray.direction.dot(outNormal) < 0;
        normal = isFront ? outNormal : -outNormal;
    }
}

interface Hittable
{
    HitRecord hit(const Ray ray, Interval rayT) const;
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

    HitRecord hit(const Ray ray, Interval rayT) const
    {
        HitRecord rec;
        float closestT = rayT.max;

        foreach (obj; objects)
        {
            HitRecord tmpRec = obj.hit(ray, Interval(rayT.min, closestT));
            if (tmpRec !is null)
            {
                closestT = tmpRec.t;
                rec = tmpRec;
            }
        }

        return rec;
    }
}
