using UnityEngine;

public class PipeCounter : MonoBehaviour
{
    public AudioSource audioSource;
   private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.CompareTag("Player"))
        {
            FindAnyObjectByType<Scire>().updateScore();
            audioSource.Play(); 
        }
    }
}
