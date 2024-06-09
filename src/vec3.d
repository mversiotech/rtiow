/// Module vec3 implements euclidean vectors with 3 components.
module vec3;
@safe @nogc nothrow:

import std.math.operations : stdIsClose = isClose;
import std.traits : isFloatingPoint, isNumeric;

/// Vec3f is a vector with 3 float components.
alias Vec3f = Vec3!float;

/// Point3f is an alias for Vec3f used to indicate location vectors.
alias Point3f = Vec3!float;

/// Vec3 is a vector with two components of an arbitrary numerical type.
struct Vec3(T) if (isNumeric!T)
{
    T x;
    T y;
    T z;

    /// cross returns the cross product between this vector and rhs.
    Vec3!T cross(Vec3!T rhs) const
    {
        Vec3!T c;

        c.x = y * rhs.z - z * rhs.y;
        c.y = z * rhs.x - x * rhs.z;
        c.z = x * rhs.y - y * rhs.x;

        return c;
    }

    /// componentMul returns the result of component-wise multiplication of this
    /// vector and rhs.
    Vec3!T componentMul(Vec3!T rhs) const
    {
        return Vec3!T(x * rhs.x, y * rhs.y, z * rhs.z);
    }

    /// dot returns the dot product between this vector and rhs.
    T dot(Vec3!T rhs) const
    {
        return x * rhs.x + y * rhs.y + z * rhs.z;
    }

    /// isZero returns true if this is a zero vector, i.e. if both components are 0.
    bool isZero() const
    {
        static if (isFloatingPoint!T)
            return stdIsClose(x, 0) && stdIsClose(y, 0) && stdIsClose(z, 0);
        else
            return x == 0 && y == 0 && z == 0;
    }

    /// lengthSquared returns the length (i.e. magnitude) of this vector squared.
    T lengthSquared() const
    {
        return x * x + y * y + z * z;
    }

    // methods only defined for floating point vectors
    static if (isFloatingPoint!T)
    {
        /// isClose returns true if this vector and rhs are approximately equal.
        ///
        /// This method is not implemented for vectors with integral components.
        bool isClose(Vec3!T rhs) const
        {
            return stdIsClose(x, rhs.x) && stdIsClose(y, rhs.y) && stdIsClose(z, rhs.z);
        }

        /// length returns the length (i.e. magnitude) of this vector.
        ///
        /// This method is not implemented for vectors with integral components.
        T length() const
        {
            import std.math : sqrt;

            return sqrt(lengthSquared());
        }

        /// unit returns a vector with the same direction as this vector and
        /// a length of 1.
        ///
        /// This method is not implemented for vectors with integral components.
        Vec3!T unit() const
        {
            return this / length();
        }
    }

    /// unary operator - returns a vector with negated components
    auto opUnary(string op : "-")() const
    {
        return Vec3!T(-x, -y, -z);
    }

    /// operator + returns the sum of two vectors.
    auto opBinary(string op : "+")(Vec3!T rhs) const
    {
        return Vec3!T(x + rhs.x, y + rhs.y, z + rhs.z);
    }

    /// operator += adds rhs to this vector.
    ref Vec3!T opOpAssign(string op : "+")(Vec3!T rhs)
    {
        x += rhs.x;
        y += rhs.y;
        z += rhs.z;
        return this;
    }

    /// operator - returns the difference of two vectors.
    auto opBinary(string op : "-")(Vec3!T rhs) const
    {
        return Vec3!T(x - rhs.x, y - rhs.y, z - rhs.z);
    }

    /// operator -= subtracts rhs from this vector.
    ref Vec3!T opOpAssign(string op : "-")(Vec3!T rhs)
    {
        x -= rhs.x;
        y -= rhs.y;
        z -= rhs.z;
        return this;
    }

    /// operator * returns the product of a vector and a scalar.
    auto opBinary(string op : "*")(T scalar) const
    {
        return Vec3!T(x * scalar, y * scalar, z * scalar);
    }

    /// operator * returns the product of a scalar and a vector.
    auto opBinaryRight(string op : "*")(T scalar) const
    {
        return Vec3!T(x * scalar, y * scalar, z * scalar);
    }

    /// operator *= multiplies this vector with a scalar.
    ref Vec3!T opOpAssign(string op : "*")(T scalar)
    {
        x *= scalar;
        y *= scalar;
        z *= scalar;
        return this;
    }

    /// operator / returns the quotient of this vector divided by a scalar.
    auto opBinary(string op : "/")(T scalar) const
    {
        static if (isFloatingPoint!T)
        {
            T inv = 1.0 / scalar;
            return this * inv;
        }
        else
        {
            return Vec3!T(x / scalar, y / scalar, z / scalar);
        }
    }

    /// operator /= divides this vector by a scalar.
    ref Vec3!T opOpAssign(string op : "/")(T scalar)
    {
        static if (isFloatingPoint!T)
        {
            T inv = 1.0 / scalar;
            x *= inv;
            y *= inv;
            z *= inv;
        }
        else
        {
            x /= scalar;
            y /= scalar;
            z /= scalar;
        }

        return this;
    }
}
