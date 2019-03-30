using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Combine : MonoBehaviour {
    public bool AddRayMaterial = false;
    void Start () {
		Transform[] transforms = this.GetComponentsInChildren<Transform>();
		List<GameObject> targetParts = new List<GameObject>();

		float startTime = Time.realtimeSinceStartup;

        List<CombineInstance> combineInstances = new List<CombineInstance>(); // mesh列表
        List<Transform> boneList = new List<Transform>(); // 骨骼列表
		List<Material> materials = new List<Material>(); // 材质列表

        // 遍历所有蒙皮网格渲染器，以计算出所有需要合并的网格、骨骼的信息
        foreach (SkinnedMeshRenderer smr in this.GetComponentsInChildren<SkinnedMeshRenderer>())
        {
			//if(materials.Count == 0)
				materials.AddRange(smr.materials);
			targetParts.Add(smr.gameObject);

			// 处理SubMesh
            // 1. SubMesh会对应同样的shareMesh
            // 2. SubMesh添加骨骼节点时会添加同样的骨骼节点到数组中
            // 3. 关键的是subMeshIndex用来标注当前是第几个SubMesh，对应需要使用的Material
            // 4. 一个Mesh有多少Sub Mesh可以在Mesh资源的Inspector窗口下发显示模型三角形和顶点数的地方显示
            for (int sub = 0; sub < smr.sharedMesh.subMeshCount; sub++)
            {
				Debug.Log(smr.gameObject.name + " has mesh " + smr.sharedMesh.ToString());
                CombineInstance ci = new CombineInstance();
                ci.mesh = smr.sharedMesh;
                ci.subMeshIndex = sub;
                combineInstances.Add(ci);
            }

			// 处理骨骼
            foreach (Transform bone in smr.bones)
            {
                foreach (Transform item in transforms)
                {
                    if (item.name != bone.name) continue;
                    boneList.Add(item);
                    break;
                }
            }
        }

        // 获取并配置角色所有的SkinnedMeshRenderer
        SkinnedMeshRenderer tempRenderer = this.gameObject.GetComponent<SkinnedMeshRenderer>();
        if (!tempRenderer) {
            tempRenderer = this.gameObject.AddComponent<SkinnedMeshRenderer>();
        }

        tempRenderer.sharedMesh = new Mesh();

        // 合并网格，刷新骨骼，附加材质
        tempRenderer.sharedMesh.CombineMeshes(combineInstances.ToArray(), false, false);
        tempRenderer.bones = boneList.ToArray();
        

        if(AddRayMaterial) {
            Mesh XRay = new Mesh();
            XRay.CombineMeshes(combineInstances.ToArray(), true, false);
            tempRenderer.sharedMesh.subMeshCount += 1;
            tempRenderer.sharedMesh.SetTriangles(XRay.GetTriangles(0), tempRenderer.sharedMesh.subMeshCount - 1);
            materials.Add(new Material(Shader.Find("XRay")));
        }
        tempRenderer.materials = materials.ToArray();


        // 销毁所有部件
        foreach (GameObject goTemp in targetParts) {
            Destroy(goTemp);
        }

        Debug.Log("合并耗时 : " + (Time.realtimeSinceStartup - startTime) * 1000 + " ms");
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
