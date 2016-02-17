local fs            = require "lemoon.fs"
local sys           = require "lemoon.sys"
local class         = require "lemoon.class"
local throw         = require "lemoon.throw"
local filepath      = require "lemoon.filepath"

local header_exts   = {
    [".h"]    = true,
    [".hpp"]  = true,
    [".hh" ]  = true,
    [".hxx"]  = true
}
local source_exts   = {
    [".c"  ]  = true,
    [".cpp"]  = true,
    [".cc" ]  = true,
    [".cxx"]  = true,
    [".m"  ]  = true,
    [".mm" ]  = true
}

local platform      = {
    ["Android"]     = "android";
    ["Linux"]       = "linux";
    ["OSX"]         = "mac";
    ["iOS"]         = "ios";
    ["Windows"]     = "win32";
}

local module        = {}
function module.ctor(task,config,srcpath,extpath)
    local obj = {
        task        = task;
        srcpath     = srcpath;
        extpath     = extpath;
        extprojs    = {};
        config      = config;
        targethost  = task.Owner.Loader.Config.TargetHost;
        targetarch  = task.Owner.Loader.Config.TargetArch;
    }

    obj.platform    = platform[obj.targethost]

    if not obj.platform then
        throw("unsupport platform :%s",obj.targethost)
    end

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

    if not fs.exists(filepath.join(obj.builddir,"lib")) then
        fs.mkdir(filepath.join(obj.builddir,"lib"),true)
    end

    if not fs.exists(filepath.join(obj.builddir,"bin")) then
        fs.mkdir(filepath.join(obj.builddir,"bin"),true)
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

local searchdir = function(path,headers,srcs)
    fs.list(path,function (entry)
        if entry == "." or entry == ".." then return end
        local file = filepath.join(path,entry)

        if fs.isdir(file) then
            return
        end

        if header_exts[filepath.ext(file)] then
            table.insert(headers,file)
        elseif source_exts[filepath.ext(file)] then
            table.insert(srcs,file)
        end
    end)
end

function module:makecocos2d(includes,dependencies)

    local libcocosdir   = filepath.join(self.projectdir,"cocos2d")
    local srcroot       = filepath.join(self.srcpath,"cocos")
    local srcfiles      = {}
    local headerfiles   = {}
    local libs          = {}

    table.insert(includes,filepath.join(self.srcpath,"cocos"))
    table.insert(includes,filepath.join(self.srcpath,"cocos/platform"))

    if self.platform == "win32" then
        table.insert(libs,"opengl32.lib")
        table.insert(libs,"ws2_32.lib")
        table.insert(libs,"winmm.lib")
    end

    if not fs.exists(libcocosdir) then
        fs.mkdir(libcocosdir,true)
    end

    for _,file in ipairs(self.config.cocos2d.srcfiles) do
        local path = filepath.join(srcroot,file)
        if header_exts[filepath.ext(file)] then
            table.insert(headerfiles,path)
        elseif source_exts[filepath.ext(file)] then
            table.insert(srcfiles,path)
        end
    end

    local deps = self.config.cocos2d.dependencies or {}

    for _,name in ipairs(deps) do
        if self:makedep(name,includes,libs) then
            table.insert(dependencies,name)
        end

    end

    for _,name in ipairs(deps[self.platform] or {}) do
        if self:makedep(name,includes,libs) then
            table.insert(dependencies,name)
        end
    end

    for name, module in pairs(self.config.cocos2d.modules) do

        if not module then
            module = {}
        end

        local deps = module.dependencies or {}

        for _,dep in ipairs(deps) do
            if self:makedep(dep,includes,libs) then
                table.insert(dependencies,dep)
            end
        end

        for _,dep in ipairs(deps[self.platform] or {}) do
            if self:makedep(dep,includes,libs) then
                table.insert(dependencies,dep)
            end
        end

        for _,dir in ipairs(module.includes or {}) do
            local path = filepath.join(srcroot,name,dir)
            table.insert(includes,path)
        end

        local src = module.src or {"."}

        for _,dir in ipairs(src) do
             searchdir(filepath.join(srcroot,name,dir),headerfiles,srcfiles)
        end

        for _,dir in ipairs(src[self.platform] or {}) do
            searchdir(filepath.join(srcroot,name,dir),headerfiles,srcfiles)
        end

        src = module.srcfiles or {}

        for _,file in ipairs(src) do

            local path = filepath.join(srcroot,name,file)
            if header_exts[filepath.ext(file)] then
                table.insert(headerfiles,path)
            elseif source_exts[filepath.ext(file)] then
                table.insert(srcfiles,path)
            end
        end

        for _,file in ipairs(src[self.platform] or {}) do
            local path = filepath.join(srcroot,name,file)
            if header_exts[filepath.ext(file)] then
                table.insert(headerfiles,path)
            elseif source_exts[filepath.ext(file)] then
                table.insert(srcfiles,path)
            end
        end
    end


    self.codegen:render(filepath.join(libcocosdir,"CMakeLists.txt"),"cocos2d.tpl",{
        name                    = "cocos2d";
        srcfiles                = srcfiles;
        headerfiles             = headerfiles;
        srcroot                 = srcroot;
        targethost              = self.targethost;
        includes                = includes;
        libs                    = libs;
        linkdirs                = { filepath.join(self.builddir,"lib") };
        outputdir               = self.builddir;
        deps                    = dependencies;
    })
end

function module:makeprebuilt(name,extra,includes,libs)
    if extra.modules then
        for n,m in pairs(extra.modules) do
            if type(m) == "string" then
                self:makeprebuilt(string.format("%s/%s",name,m),{},includes,libs)
            else
                self:makeprebuilt(string.format("%s/%s",name,n),m,includes,libs)
            end
        end

        return
    end

    if not extra.includes then
        extra.includes = { "./include" }
    end

    for _,i in ipairs(extra.includes) do
        local include = filepath.join(self.extpath,name,i)

        table.insert(includes,include)
        table.insert(includes,filepath.join(include,self.platform))
    end

    for _,dir in ipairs(extra.includes[self.platform] or {}) do
        local include = filepath.join(self.extpath,name,dir)
        table.insert(includes,include)
    end

    local libpath = filepath.join(self.extpath,name,"prebuilt",self.platform)

    if not fs.exists(libpath) then
        libpath = filepath.join(self.extpath,name,"prebuilt")
    end

    if self.platform == "win32" then
        libext = ".lib"
        dllext = ".dll"
        libdir = "lib"
        dlldir = "bin"
    elseif self.platform == "mac" then
        libext = ".a"
        dllext = ".dylib"
        libdir = "lib"
        dlldir = "lib"
    else
        libext = ".a"
        dllext = ".so"
        libdir = "lib"
        dlldir = "lib"
    end

    self:copylibs(extra,libpath,libs)

end

function module:copylibs(extra,path,libs)
    fs.list(path,function(entry)
        if entry == "." or entry == ".." then
            return
        end

        source = filepath.join(path,entry)

        if fs.isdir(source) then
            if entry == "release-lib" then
                self:copylibs(extra,filepath.join(path,"release-lib"),libs)
            end
            return
        end

        if filepath.ext(entry) == libext then
            target = filepath.join(self.builddir,libdir,entry)
            if not extra.vslibtrack or self.platform ~= "win32" then
                table.insert(libs,entry)
            end
        elseif filepath.ext(entry) == dllext then
            target = filepath.join(self.builddir,dlldir,entry)
        end

        if source then
            fs.copy_file(source,target,fs.update_existing)
        end
    end)
end

function module:makedepsrc(name,extra,includes,libs)

    local srcroot               = filepath.join(self.extpath,name)
    local srcfiles              = {}
    local headerfiles           = {}
    local local_includes        = {
        filepath.join(self.srcpath,"cocos");
        filepath.join(self.srcpath,"cocos/platform");
    }

    if not extra.includes then
        extra.includes = { "." }
    end

    if not extra.src then
        extra.src = { "." }
    end

    for _,dir in ipairs(extra.includes) do
        local include = filepath.join(self.extpath,name,dir)
        table.insert(includes,include)
        table.insert(local_includes,include)
    end

    for _,dir in ipairs(extra.includes[self.platform] or {}) do
        local include = filepath.join(self.extpath,name,dir)
        table.insert(includes,include)
        table.insert(local_includes,include)
    end


    for _,dir in ipairs(extra.src) do
        local path = filepath.join(self.extpath,name,dir)
        fs.list(path,function(entry)
            if entry == "." or entry == ".." then
                return
            end

            local newpath = filepath.join(path,entry)

            if header_exts[filepath.ext(entry)] then
                table.insert(headerfiles,newpath)
            elseif source_exts[filepath.ext(entry)] then
                table.insert(srcfiles,newpath)
            end
        end)
    end

    local outputdir = filepath.join(self.projectdir,name)

    if not fs.exists(outputdir) then
        fs.mkdir(outputdir,true)
    end

    table.insert(libs,name)

    self.codegen:render(filepath.join(outputdir,"CMakeLists.txt"),"extra.tpl",{
        name                    = name;
        srcfiles                = srcfiles;
        headerfiles             = headerfiles;
        srcroot                 = srcroot;
        targethost              = self.targethost;
        includes                = local_includes;
        libs                    = {};
        outputdir               = self.builddir
    })

end

function module:makedep(name,includes,libs)
    local extra = self.config.extra[name]

    if not extra then
        print(string.format("warning : unknown extra module(%s)",name))
        return
    end

    if extra.prebuilt then
        self:makeprebuilt(name,extra,includes,libs)
        return false
    else
        self:makedepsrc(name,extra,includes,libs)
        return true
    end
end

function module:makelibsimulator(includes)
    local config = self.config.libsimulator

    local srcroot               = filepath.join(self.srcpath,"tools/simulator/libsimulator")
    local srcfiles              = {}
    local headerfiles           = {}
    local includes              = {
        filepath.join(self.srcpath,"cocos"),
        filepath.join(self.srcpath,"cocos/platform"),
        filepath.join(self.srcpath,"cocos/platform/desktop"),
        filepath.join(self.srcpath,"cocos/editor-support"),
        self.extpath,
        filepath.join(self.extpath,"chipmunk/include/chipmunk"),
        filepath.join(self.extpath,"curl/include",self.platform),
        filepath.join(self.extpath,"glfw3/include",self.platform)
    }

    if self.platform == "win32" then
        table.insert(includes,filepath.join(self.extpath,"win32-specific/zlib/include"))
        table.insert(includes,filepath.join(self.extpath,"win32-specific/gles/include/OGLES"))
    else
        table.insert(includes,filepath.join(self.extpath,"zlib/include"))
    end

    if not config.includes then
        config.includes = { "." }
    end

    if not config.src then
        config.src = { "." }
    end

    for _,dir in ipairs(config.includes) do
        local include = filepath.join(srcroot,dir)
        table.insert(includes,1,include)
    end

    for _,dir in ipairs(config.includes[self.platform] or {}) do
        local include = filepath.join(srcroot,dir)
        table.insert(includes,1,include)
    end

    for _,dir in ipairs(config.src) do
        local path = filepath.join(srcroot,dir)
        fs.list(path,function(entry)
            if entry == "." or entry == ".." then
                return
            end

            local newpath = filepath.join(path,entry)

            if header_exts[filepath.ext(entry)] then
                table.insert(headerfiles,newpath)
            elseif source_exts[filepath.ext(entry)] then
                if entry == "Widget_mac.mm" then
                    if self.platform == "mac" then
                        table.insert(srcfiles,newpath)
                    end
                else
                    table.insert(srcfiles,newpath)
                end
            end
        end)
    end

    for _,dir in ipairs(config.src[self.platform] or {}) do
        local path = filepath.join(srcroot,dir)
        fs.list(path,function(entry)
            if entry == "." or entry == ".." then
                return
            end

            local newpath = filepath.join(path,entry)

            if header_exts[filepath.ext(entry)] then
                table.insert(headerfiles,newpath)
            elseif source_exts[filepath.ext(entry)] then
                if entry ~= "SimulatorWin.cpp" then
                    table.insert(srcfiles,newpath)
                end
            end
        end)
    end

    local outputdir = filepath.join(self.projectdir,"libsimulator")

    if not fs.exists(outputdir) then
        fs.mkdir(outputdir,true)
    end

    self.codegen:render(filepath.join(outputdir,"CMakeLists.txt"),"libsimulator.tpl",{
        name                    = "libsimulator";
        srcfiles                = srcfiles;
        headerfiles             = headerfiles;
        srcroot                 = srcroot;
        targethost              = self.targethost;
        includes                = includes;
        libs                    = {};
        outputdir               = self.builddir
    })
end

function module:makeproject()

    local includes = {}
    local deps = {}

    self:makecocos2d(includes,deps)

    self:makelibsimulator()

    table.insert(deps,"libsimulator")

    local cmakefilepath = filepath.join(self.projectdir,"CMakeLists.txt")

    self.codegen:render(cmakefilepath,"project.tpl",{
       name                    = filepath.base(self.task.Owner.Name);
       targethost              = self.targethost;
       externals               = deps;
   })
end


return module
