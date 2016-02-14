local fs            = require "lemoon.fs"
local sys           = require "lemoon.sys"
local class         = require "lemoon.class"
local filepath      = require "lemoon.filepath"


local module        = {}
function module.ctor(task,srcpath,extpath)
    local obj = {
        task        = task;
        srcpath     = srcpath;
        extpath     = extpath;
        extprojs    = {};
    }

    local tmpdir = task.Owner.Loader.Temp

    obj.projectdir = filepath.join(
       tmpdir,"cmake",
       loader.Config.TargetHost .. "-" .. loader.Config.TargetArch)

    obj.builddir = filepath.join(
        tmpdir,"clang",
        loader.Config.TargetHost .. "-" .. loader.Config.TargetArch)

    if not fs.exists(obj.projectdir) then
        fs.mkdir(obj.projectdir,true)
    end

    if not fs.exists(obj.builddir) then
        fs.mkdir(obj.builddir,true)
    end

    obj.codegen = class.new("lemoon.codegen")
    local templatedir = filepath.join(task.Package.Path,"template")
    fs.list(templatedir,function (entry)

        if entry == "." or entry == ".." then
            return
        end

        local path = filepath.join(templatedir,entry)

        if fs.isdir(path) then
            return
        end

        local f = io.open(path)

        obj.codegen:compile(filepath.base(path),f:read("a"))
    end)

    return obj
end

function module:makeproject()

end


return module
