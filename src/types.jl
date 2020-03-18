import Base: convert, ==, ≈

abstract type GroundType end

const FuzzyInt = Union{Missing, UInt}
const VecOrGround = Union{GroundType, Vector}

struct Clock <: GroundType
end

ispassive(::Clock) = true

struct UInteger <: GroundType
    width::FuzzyInt
end
UInteger() = UInteger(missing)

ispassive(::UInteger) = true

struct SInteger <: GroundType
    width::FuzzyInt
end
SInteger() = SInteger(missing)

ispassive(::SInteger) = true

struct Analog <: GroundType
    width::FuzzyInt
end
Analog() = Analog(missing)

ispassive(::Analog) = true

for (x, y) in Base.product((:Clock, :UInteger, :SInteger, :Analog), (:Clock, :UInteger, :SInteger, :Analog))
    if x == y
        @eval ==(::$x, ::$y) = true
    else
        @eval ==(::$x, ::$y) = false
    end
end
≈(x::GroundType, y::GroundType) = (x == y)

ispassive(x::Vector) = all(ispassive, x)
≈(x::Vector, y::Vector) = all(x .≈ y)

struct BundleUnit
    type::F where F
    flip::Bool

    BundleUnit(type, flip) = _checkbundletype(typeof(type)) ? new(type, flip) :
        error("Cannot create BundleUnit with type == $(typeof(type)) (must be recursively terminate in a GroundType).")
end

ispassive(x::BundleUnit) = ispassive(x.type) && !x.flip
==(x::BundleUnit, y::BundleUnit) = (x.type == y.type) && (x.flip == y.flip)
==(x, ::BundleUnit) = false
==(::BundleUnit, x) = false
≈(x::BundleUnit, y::BundleUnit) = (x == y)

const Bundle = Dict{Symbol, BundleUnit}

_checkbundletype(::Type{T}) where T <: GroundType = true
_checkbundletype(::Type{BundleUnit}) = true
_checkbundletype(::Type{Bundle}) = true
_checkbundletype(::Type{Vector{T}}) where T = _checkbundletype(T)
_checkbundletype(x) = false

ispassive(x::Bundle) = all(ispassive, values(x))
==(x::Bundle, y::Bundle) = all(z -> (z[1].first == z[2].first) && (z[1].second == z[2].second), zip(x, y))
==(x, ::Bundle) = false
==(::Bundle, x) = false
≈(x::Bundle, y::Bundle) = !any(k -> !(x[k] ≈ y[k]), intersect(keys(x), keys(y)))

const FIRType = Union{VecOrGround, Bundle}
convert(::Type{BundleUnit}, x::FIRType) = BundleUnit(x, false)
convert(::Type{BundleUnit}, x::Tuple{T, Bool}) where T <: FIRType = BundleUnit(x...)