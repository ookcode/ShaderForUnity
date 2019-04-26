using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Dissolve : MonoBehaviour {

	// Use this for initialization
	const float dissoveTimeMax = 2.0f;
	float dissolveTime = 0;
	List<Material> _materials;

	void Start () {
		_materials = new List<Material>();
		foreach(Transform trans in transform) {
			var render = trans.GetComponent<SkinnedMeshRenderer>();
			Debug.Log(render);
			if(render != null) {
				var material = render.material;
				_materials.Add(material);
			}
		}
	}
	
	// Update is called once per frame
	void Update () {
		if(dissolveTime > 0) {
			dissolveTime -= Time.deltaTime;
			float percent = (dissoveTimeMax - dissolveTime) / dissoveTimeMax;
			foreach(var material in _materials) {
				material.SetFloat("_DissolveThreshold", percent);
			}
		}
	}

	void OnGUI () {
        if (GUI.Button(new Rect(50, 50, 120, 40), "Dissolve")) {
            dissolveTime = dissoveTimeMax;
        }
	}
}
