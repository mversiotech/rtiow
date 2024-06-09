module material;
@safe nothrow:

import color;
import hittable;
import random;
import ray;
import vec3;

interface Material
{
    Ray scatter(const Ray rayIn, const HitRecord rec, out Color attenuation) const;
}

class Lambertian: Material
{
    const Color albedo;

    this(Color albedo)
    {
        this.albedo = albedo;
    }

    Ray scatter(const Ray rayIn, const HitRecord rec, out Color attenuation) const
    {
        auto scatterDir = rec.normal + randomUnitVec3f();
        if (scatterDir.isZero())
            scatterDir = rec.normal;

        auto scattered = new Ray(rec.p, scatterDir);
        attenuation = albedo;
        return scattered;
    }
}

class Metal: Material
{
    const Color albedo;
    const float fuzz;

    this(Color albedo, float fuzz)
    {
        this.albedo = albedo;
        this.fuzz = (fuzz < 1.0f) ? fuzz : 1.0f;
    }

    Ray scatter(const Ray rayIn, const HitRecord rec, out Color attenuation) const
    {
        auto reflected = reflect(rayIn.direction, rec.normal).unit();
        reflected += fuzz * randomUnitVec3f();
        auto scattered = new Ray(rec.p, reflected);
        attenuation = albedo;
        if (scattered.direction.dot(rec.normal) > 0)
            return scattered;

        return null;
    }

    private static Vec3f reflect(Vec3f v, Vec3f n)
    {
        return v - 2.0f * v.dot(n) * n;
    }
}
