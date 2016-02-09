local fs            = require "lemoon.fs"
local class         = require "lemoon.class"
local filepath      = require "lemoon.filepath"
local lunajson      = require "lunajson"

local name          = "github.com/cocos2d/cocos2d-x"
local version       = "cocos2d-x-3.10"

local curl          = class.new("curl")
local console       = class.new("lemoon.log","console")


local init = function(self)
    cocos    = self.Owner.Properties.cocos

    if cocos.name == nil then
        cocos.name = name
    end

    if cocos.version == nil then
        cocos.version = version
    end
end

local cmake = nil

-- sync cocos repo
task.cocosnew = function(self)
    init(self)

    local sync = self.Owner.Loader.Sync

    source_path = sync:sync(cocos.name,cocos.version)

    local externalconfig = filepath.join(source_path,"external/config.json")

    local externalversion = ""

    if fs.exists(externalconfig) then
        local fp = io.open(externalconfig,"r")
        local content = fp:read("a")
        externalversion = lunajson.decode(content)["version"]
    end

    print(string.format("cocos name            : %s",cocos.name))
    print(string.format("cocos version         : %s",cocos.version))
    print(string.format("cocos path            : %s",source_path))
    print(string.format("cocos external config : %s",externalversion))
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
