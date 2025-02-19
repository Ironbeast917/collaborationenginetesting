function Test(number, string, boolean)
    DebugLog(number)
    DebugLog(string)
    DebugLog(boolean)
end

ModelSpawner.SpawnModel("https://raw.githubusercontent.com/Ironbeast917/collaborationenginetesting/refs/heads/main/Map.glb", true, NewVector3(0, 0, 0), NewQuaternion(0, 0, 0, 0), nil)
Entity.CallFunction("Test", 12.412, "Hi", true)