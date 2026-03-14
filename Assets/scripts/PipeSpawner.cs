using UnityEngine;

public class PipeSpawner : MonoBehaviour
{

    public GameObject pipePrefab;
    public float heightRange = 0.5f;
    public float maxtime = 1.75f;

    private float timer = 0;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        SpawnPipe();
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;
        if (timer > maxtime)
        {
            SpawnPipe();
            timer = 0;
        }
    }

    public void SpawnPipe()
    {
        Vector3 spawnPosition = transform.position + new Vector3(0, Random.Range(-heightRange, heightRange), 0);
        GameObject newPipe;
        newPipe = Instantiate(pipePrefab, spawnPosition, Quaternion.identity);

        Destroy(newPipe, 15f);
    }
}
