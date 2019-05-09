using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RadialBlur : MonoBehaviour {

	Camera _camera;
	Texture2D _tex;
	RenderTexture _rt;
	public RawImage raw;

	void Start () {
		_camera = GetComponent<Camera>();
		_rt = new RenderTexture(Screen.width, Screen.height, 0);
		_camera.targetTexture = _rt;
	}
	
	void Update () {
		
	}

	void OnPostRender() {
		if(_tex != null) {
			Destroy(_tex);
		}
		_tex = new Texture2D(_rt.width, _rt.height);
		_tex.ReadPixels(new Rect(0, 0, _rt.width, _rt.height), 0, 0);
		_tex.Apply();
		raw.texture = _tex;
	}
}
