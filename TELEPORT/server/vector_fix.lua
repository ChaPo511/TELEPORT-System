if not vector4 then
    function vector4(x, y, z, w)
        return {x = x, y = y, z = z, w = w, __type = "vector4"}
    end
end

if not vector3 then
    function vector3(x, y, z)
        return {x = x, y = y, z = z, __type = "vector3"}
    end
end
