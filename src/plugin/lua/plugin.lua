local fs            = require "lemoon.fs"
local sys           = require "lemoon.sys"
local class         = require "lemoon.class"
local filepath      = require "lemoon.filepath"
local lunajson      = require "lunajson"

local name          = "github.com/cocos2d/cocos2d-x"
local version       = "cocos2d-x-3.10"

local curl          = class.new("curl")
local console       = class.new("lemoon.log","console")

local cmake = nil

local init = function(self)
    cocos    = self.Owner.Properties.cocos

    if cocos.name == nil then
        cocos.name = name
    end

    if cocos.version == nil then
        cocos.version = version
    end

    local ok, cmakepath = sys.lookup("cmake")

    if not ok then
        throw("check the cmake command line tools -- failed, not found")
    end

    cmake = cmakepath
end



local checkcocosenv = function(self)
    init(self)

    local sync = self.Owner.Loader.Sync

    sourcepath = sync:sync(cocos.name,cocos.version)

    local externalconfig = filepath.join(sourcepath,"external/config.json")

    local externalversion = ""

    if fs.exists(externalconfig) then
        local fp = io.open(externalconfig,"r")
        local content = fp:read("a")
        externalversion = lunajson.decode(content)["version"]
    end
    -- now check the external libs
    local externalname = "github.com/cocos2d/cocos2d-x-3rd-party-libs-bin"
    externalpath = sync:sync(externalname,externalversion)

    print(string.format("cocos name            : %s",cocos.name))
    print(string.format("cocos version         : %s",cocos.version))
    print(string.format("cocos path            : %s",sourcepath))
    print(string.format("cocos ext version     : %s",externalversion))
    print(string.format("cocos ext path        : %s",externalpath))
end

-- sync cocos repo
task.cocosnew = function(self)

    checkcocosenv(self)

    class.new("cocos",self,sourcepath,externalpath):makeproject()

end
task.cocosnew.Desc = "init/prepare the cocos project"

-- set or get the cocos framework path
task.cocospath = function(self,path)
    init(self)

    local repo      = self.Owner.Loader.GSMake.Repo

    print(string.format(
                "config gsmake-cocos\nname :%s\nversion :%s",
                cocos.name,cocos.version))

    if not path then
        local path,ok = repo:query_source(cocos.name,cocos.version)
        if not ok then
            console:E("cocos source not found !!!!!!!",path)
        else
            print(string.format("path :%s",path))
        end
    else
        local path = filepath.abs(path)
        print(string.format("set new path :%s",path))
        repo:save_source(cocos.name,cocos.version,path,path,true)
    end

end
task.cocospath.Desc = "get/set the cocos framework path"
