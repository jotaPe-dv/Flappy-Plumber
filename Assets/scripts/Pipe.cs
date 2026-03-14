using UnityEngine;

public class Pipe : MonoBehaviour
{
    public float speed = 0.75f;

    // Update is called once per frame
    void Update()
    {
        transform.position += Vector3.left * speed * Time.deltaTime;

        if (transform.position.x < -10)
        {
            Destroy(gameObject);
        }
        
    }
}
