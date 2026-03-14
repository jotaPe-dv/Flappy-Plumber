using UnityEngine;

public class FloorMOve : MonoBehaviour
{
    public float speed = 2f;
    private SpriteRenderer sr;
    private float spriteWidth;

    void Start()
    {
        sr = GetComponent<SpriteRenderer>();
        spriteWidth = sr.size.x;
    }

    void Update()
    {
        sr.size = new Vector2(sr.size.x + speed * Time.deltaTime, sr.size.y);

        if (sr.size.x <= 0)
            sr.size = new Vector2(spriteWidth, sr.size.y);
    }
}
