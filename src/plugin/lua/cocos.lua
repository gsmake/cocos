local fs            = require "lemoon.fs"
local sys           = require "lemoon.sys"
local class         = require "lemoon.class"
local filepath      = require "lemoon.filepath"
local module        = {}


local cocos2d_submodules = {
    "2d","base","math","navmesh",
    "physics","platform",
    "renderer"
}

local src_file_exts = {
    "[^.]*%.mm","[^.]*%.cc","[^.]*%.cpp","[^.]*%.c"
}

local header_file_exts = {
    "[^.]*%.h","[^.]*%.hpp","[^.]*%.hxx"
}


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

function module:include_platform_specific(includes,libs,headerfiles,srcfiles)
    local host = loader.Config.TargetHost
    local arch = loader.Config.TargetArch

    if host == "Windows" then
        specific = "win32-specific"
        platform = {"win32"}
    elseif host == "WP10" then
        specific = "win10-specific"
    elseif host == "iOS" then
        platform = {"ios","apple"}
    elseif host == "OSX" then
        platform = {"mac","apple"}
    elseif host == "Linux" then
        platform = {"linux"}
    elseif host == "Android" then
        platform = {"android"}
    end

    if arch == ARM then
        arch = "arm"
    else
        arch = "win32"
    end

    for _,dir in ipairs(platform or {}) do
        local srcpath = filepath.join(self.srcpath,"cocos/platform",dir)

        fs.list(srcpath,function (entry)
            if entry == ".." or entry == "." then
                return
            end

            local ext  = filepath.ext(entry)
            local path = filepath.join(srcpath,entry)

            if ext == ".cpp" or ext == ".mm" then
                table.insert(srcfiles,path)
            elseif ext == ".h" then
                table.insert(headerfiles,path)
            end
        end)
    end

    if not specific then
        return
    end

    local path = filepath.join(self.extpath,specific)

    fs.list(path,function (entry)
        if ".." == entry or "." == entry then return end

        local libpath = filepath.join(path,entry)
        if entry == "gles" then
            table.insert(includes,filepath.join(libpath,"include/OGLES"))
        else
            table.insert(includes,filepath.join(libpath,"include"))
        end

        local prebuilt = filepath.join(libpath,"prebuilt")
        fs.list(prebuilt,function(entry)
            if ".." == entry or "." == entry then return end

            if filepath.ext(entry) == ".lib" then
                table.insert(libs,filepath.join(prebuilt,entry))
            else

                local targetdir = filepath.join(self.builddir,"bin")

                if not fs.exists(targetdir) then
                    fs.mkdir(targetdir,true)
                end

                local src = filepath.join(prebuilt,entry)
                local obj = filepath.join(targetdir,entry)

                fs.copy_file(src,obj,fs.update_existing)
            end
        end)
    end)

end

function module:make_external_prebuilt(path,includes,libs)
    local host = loader.Config.TargetHost
    local arch = loader.Config.TargetArch

    if host == "Windows" then
        platform = "win32"
        libext   = ".lib"
        soext    = ".dll"
        sodir    = "bin"
    elseif host == "WP10" then
        platform = "win10"
        libext   = ".lib"
        soext    = ".dll"
        sodir    = "bin"
    elseif host == "iOS" then
        platform = "ios"
        libext   = ".a"
        soext    = ".dylib"
        sodir    = "lib"
    elseif host == "OSX" then
        platform = "mac"
        libext   = ".a"
        soext    = ".dylib"
        sodir    = "lib"
    elseif host == "Linux" then
        platform = "linux"
        libext   = ".a"
        soext    = ".so"
        sodir    = "lib"
    elseif host == "Android" then
        platform = "android"
        libext   = ".a"
        soext    = ".so"
        sodir    = "lib"
    end



    if filepath.base(path) == "freetype2" then
        include  = filepath.join(path,"include",platform,"freetype2")
    elseif filepath.base(path) == "chipmunk" then
        include  = filepath.join(path,"include","chipmunk")
    else
        include  = filepath.join(path,"include",platform)
    end



    if filepath.base(path) == "sqlite3" then
        prebuilt = filepath.join(path,"libraries",platform)
    else
        prebuilt = filepath.join(path,"prebuilt",platform)
    end



    if not fs.exists(prebuilt) then
        return
    end

    table.insert(includes,include)

    if filepath.base(path) == "chipmunk" then
        prebuilt = filepath.join(prebuilt,"release-lib")
    end

    fs.list(prebuilt,function(entry)
        if ".." == entry or "." == entry then return end

        if filepath.ext(entry) == libext then
            if host == "Windows" and entry:match("^[^-]*-2015.lib$") ~= entry then
                return
            end

            table.insert(libs,filepath.join(prebuilt,entry))
        else

            local targetdir = filepath.join(self.builddir,sodir)

            if not fs.exists(targetdir) then
                fs.mkdir(targetdir,true)
            end

            local src = filepath.join(prebuilt,entry)
            local obj = filepath.join(targetdir,entry)

            fs.copy_file(src,obj,fs.update_existing)
        end
    end)

end

function module:make_external_sources(path,headerfiles,srcfiles)



    for _,pattern in ipairs(header_file_exts) do

        fs.match(path,pattern,nil,function(newpath)
            newpath = filepath.toslash(filepath.clean(newpath))

            table.insert(headerfiles,newpath)
        end)
    end

    for _,pattern in ipairs(src_file_exts) do
        fs.match(path,pattern,nil,function(newpath)
            newpath = filepath.toslash(filepath.clean(newpath))
            table.insert(srcfiles,newpath)
        end)
    end
end

function module:make_external(name,includes,libs)

    local path = filepath.join(self.extpath,name)

    if fs.exists(filepath.join(path,"include")) then
        self:make_external_prebuilt(path,includes,libs)
    elseif name:match("^[^-]*-specific$") == name then
        return
    else
        local srcfiles      = {}
        local headerfiles   = {}
        table.insert(includes,path)
        self:make_external_sources(path,headerfiles,srcfiles)

        local externalproject = filepath.join(self.projectdir,"external",name)

        if not fs.exists(externalproject) then
            fs.mkdir(externalproject,true)
        end

        self.codegen:render(filepath.join(externalproject,"CMakeLists.txt"),"cocos2d.tpl",{
            name                    = name;
            srcfiles                = srcfiles;
            headerfiles             = headerfiles;
            srcroot                 = filepath.join(self.extpath,name);
            targethost              = loader.Config.TargetHost;
            includes                = includes;
            libs                    = {};
            outputdir               = self.builddir
        })
        table.insert(libs,name)
        table.insert(self.extprojs,"external/" .. name)
    end
end

function module:makeaudio(headerfiles,srcfiles)

    local host = loader.Config.TargetHost

    if host == "Windows" then
        platform = "win32"
    elseif host == "WP10" then
        platform = "win10"
    elseif host == "iOS" then
        platform = "ios"
    elseif host == "OSX" then
        platform = "mac"
    elseif host == "Linux" then
        platform = "linux"
    elseif host == "Android" then
        platform = "android"
    end

    local srcpath = filepath.join(self.srcpath,"cocos/audio")

    fs.list(srcpath,function (entry)
        if entry == ".." or entry == "." then
            return
        end

        local path = filepath.join(srcpath,entry)

        if fs.isdir(path) then

            if entry ~= platform then return end

            fs.list(path,function (entry)

                if entry == ".." or entry == "." then
                    return
                end

                local ext  = filepath.ext(entry)
                local path = filepath.join(path,entry)

                if ext == ".cpp" or ext == ".mm" or ext == ".m" then
                    table.insert(srcfiles,path)
                elseif ext == ".h" then
                    table.insert(headerfiles,path)
                end

            end)

            return
        end

        local ext  = filepath.ext(entry)
        local path = filepath.join(srcpath,entry)

        if ext == ".cpp" or ext == ".mm" or ext == ".m" then
            table.insert(srcfiles,path)
        elseif ext == ".h" then
            table.insert(headerfiles,path)
        end

    end)
end

function module:makenetwork(headerfiles,srcfiles)
    local srcpath = filepath.join(self.srcpath,"cocos/network")

    fs.list(srcpath,function (entry)
        if entry == ".." or entry == "." then
            return
        end

        local ext  = filepath.ext(entry)
        local path = filepath.join(srcpath,entry)

        if entry:match("^[^-]*-android%.[^%.]+$") == entry and host ~= "Android" then
            return
        end

        if  entry:match("^[^-]*-apple%.[^%.]+$") == entry and host ~= "iOS" and host ~= "OSX" then
            return
        end

        if  entry:match("^[^-]*-winrt%.[^%.]+$") == entry and host ~= "WINRT" then
            return
        end

        if ext == ".cpp" or ext == ".mm" or ext == ".m" then
            table.insert(srcfiles,path)
        elseif ext == ".h" then
            table.insert(headerfiles,path)
        end
    end)
end

function module:makelibcocos2d()
    local libcocosdir = filepath.join(self.projectdir,"cocos2d")

    if not fs.exists(libcocosdir) then
        fs.mkdir(libcocosdir,true)
    end

    local srcfiles      = {}
    local headerfiles   = {}

    local host = loader.Config.TargetHost

    for _,module in ipairs(cocos2d_submodules) do

        local srcpath = filepath.join(self.srcpath,"cocos",module)

        fs.list(srcpath,function (entry)
            if entry == ".." or entry == "." then
                return
            end

            local ext  = filepath.ext(entry)
            local path = filepath.join(srcpath,entry)

            if ext == ".cpp" or ext == ".mm" or ext == ".m" then
                table.insert(srcfiles,path)
            elseif ext == ".h" then
                table.insert(headerfiles,path)
            end
        end)
    end

    self:makenetwork(headerfiles,srcfiles)
    self:makeaudio(headerfiles,srcfiles)

    local includes  = {
        filepath.join(self.srcpath,"cocos");
        filepath.join(self.srcpath,"cocos/platform");
        filepath.join(self.srcpath,"cocos/audio/include");

        self.extpath
     }
    local libs      = {}

    self:include_platform_specific(includes,libs,headerfiles,srcfiles)

    local skips = {
        ["fbx-conv"] = true;
        ["version.json"] = true;
        ["json"] = true;
        ["lua"] = true;
    }

    if loader.Config.TargetHost == "Windows" then
        skips["bullet"] = true
        skips["flatbuffers"] = true
    end

    fs.list(filepath.join(self.extpath),function (entry)
        if entry == ".." or entry == "." then
            return
        end

        if skips[entry] then
            return
        end

        self:make_external(entry,includes,libs)
    end)


    self.codegen:render(filepath.join(libcocosdir,"CMakeLists.txt"),"cocos2d.tpl",{
        name                    = "cocos2d";
        srcfiles                = srcfiles;
        headerfiles             = headerfiles;
        srcroot                 = filepath.join(self.srcpath,"cocos");
        targethost              = loader.Config.TargetHost;
        includes                = includes;
        libs                    = libs;
        outputdir               = self.builddir
    })
end

function module:makeproject()

    local cmakefilepath = filepath.join(self.projectdir,"CMakeLists.txt")

    self:makelibcocos2d()

    self.codegen:render(cmakefilepath,"project.tpl",{
        name                    = filepath.base(self.task.Owner.Name);
        targethost              = loader.Config.TargetHost;
        externals               = self.extprojs;
    })

end


return module
