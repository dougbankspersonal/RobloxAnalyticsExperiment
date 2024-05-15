local analytics = {}

local cachedGameId
local cachedActionCount
local cachedStartTime 
local cachedGameConfigName
local cachedGameLevelName

local GameAnalytics = require(game.ReplicatedStorage.GameAnalytics)

analytics.gameConfigNames = {   
    "v1.0.01",
    "v1.0.02",
    "v1.0.03",
    "v1.0.04",
}

analytics.gameLevelNames = {   
    "Interview",
    "First Day",
    "Internship",
    "FullTime",
    "HolidayRush",
    "OfficePolitics",
}

analytics.playerActions = {
    "Attack", 
    "Defend",
    "Heal", 
    "Eat",
}

analytics.EventTypes = {
    "TakeAction", 
    "StartGame", 
    "EndGameSuccessActions", 
    "EndGameSuccessTime", 
    "EndGameFailureActions",
    "EndGameFailureTime",
}

analytics.init = function()
    print("Doug: GameAnalytics = ", GameAnalytics)

    GameAnalytics:setEnabledInfoLog(true)
    GameAnalytics:configureBuild("v 1.0.01")
    GameAnalytics:initialize({
        useCustomUserId = true,
    })
    -- game config.
    GameAnalytics:configureAvailableCustomDimensions01(analytics.gameConfigNames)
    GameAnalytics:configureAvailableCustomDimensions02(analytics.gameLevelNames)
    GameAnalytics:initServer("4d63aaafed7246a509eb983aad41ad96", "0735b711086a7f07fc95c3904874d3fcaef31bc9")

    print("Doug: Analytics initialized")
end

local function getCustomUserId()
    local player = game.Players.LocalPlayer
    return player.DisplayName
end

local function getFullEventName(eventName)
    return cachedGameConfigName .. ":" .. cachedGameLevelName .. ":" .. eventName
end

analytics.recordGameStart = function(gameId, gameConfigName, gameLevelName, mockPlayerDescs)
    cachedGameId = gameId
    cachedActionCount = 0
    cachedStartTime = os.time()
    cachedGameConfigName = gameConfigName
    cachedGameLevelName = gameLevelName

    local eventName = getFullEventName("StartGame")    
    GameAnalytics.NewDesignEvent (eventName, #mockPlayerDescs)

    print("Doug: Send to analytics: game start")
    print("Doug:   cachedGameId = ", cachedGameId)
    print("Doug:   cachedActionCount = ", cachedActionCount)
    print("Doug:   cachedStartTime = ", cachedStartTime)
    print("Doug:   cachedGameConfigName = ", cachedGameConfigName)
    print("Doug:   cachedGameLevelName = ", cachedGameLevelName)
    print("Doug:   numPlayers = ", #mockPlayerDescs)
end

analytics.recordGameEnd = function(outcome)
    local endTime = os.time()

    local totalTimeInSeconds = endTime - cachedStartTime

    if outcome then 
        local eventName = getFullEventName("EndGameSuccessActions")    
        GameAnalytics.NewDesignEvent (eventName, cachedActionCount)
        eventName = getFullEventName("EndGameSuccessTime")    
        GameAnalytics.NewDesignEvent (eventName, totalTimeInSeconds)
    else
        local eventName = getFullEventName("EndGameFailureActions")    
        GameAnalytics.NewDesignEvent (eventName, cachedActionCount)
        eventName = getFullEventName("EndGameFailureTime")    
        GameAnalytics.NewDesignEvent (eventName, totalTimeInSeconds)
    end

    print("Doug: Send to analytics: game start")
    print("Doug:   cachedGameId = ", cachedGameId)
    print("Doug:   cachedActionCount = ", cachedActionCount)
    print("Doug:   totalTimeInSeconds = ", totalTimeInSeconds)
    print("Doug:   outcome = ", outcome)
end

analytics.recordAction = function(actionName, playerId)
    cachedActionCount = cachedActionCount + 1
    local eventName = getFullEventName("TakeAction")    
    GameAnalytics.NewDesignEvent (eventName, 1)

    print("Doug: Send to analytics: game action")
    print("Doug:   cachedGameId = ", cachedGameId)
    print("Doug:   cachedActionCount = ", cachedActionCount)
    print("Doug:   playerId = ", playerId)
    print("Doug:   actionName = ", actionName)
end

return analytics