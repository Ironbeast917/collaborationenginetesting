ModelSpawner.SpawnModel("https://raw.githubusercontent.com/Ironbeast917/collaborationenginetesting/refs/heads/main/Map.glb", true, NewVector3(0, 0, 0), NewQuaternion(0, 0, 0, 0), nil)
Entity.SetFloat("TestVar", 12.5234)

function Update()
    DebugLog(Entity.GetFloat("TestVar"))
end