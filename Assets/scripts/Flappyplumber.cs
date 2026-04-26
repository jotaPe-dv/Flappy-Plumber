using UnityEngine;
using UnityEngine.InputSystem;
using System.Collections;

public class Flappyplumber : MonoBehaviour
{
    public float velocity = 2;
    public Rigidbody2D rb2D;
    public float rotationSpeed = 25;

    public AudioSource audioSource;
    public float gameOverDelay = 0.6f;
    public Color collisionPulseColor = new Color(1f, 0.2f, 0.2f, 1f);
    public float pulseSpeed = 18f;

    private Renderer modelRenderer;
    private bool isDead;

    // Guardamos los colores originales de todos los materiales
    private Color[] originalColors;
    private Material[] instanceMaterials;

    void Start()
    {
        //localsiño
        rb2D = GetComponent<Rigidbody2D>();
        modelRenderer = GetComponentInChildren<Renderer>();

        if (modelRenderer != null)
        {
            // Obtenemos instancias propias de todos los materiales
            instanceMaterials = modelRenderer.materials;
            originalColors = new Color[instanceMaterials.Length];

            for (int i = 0; i < instanceMaterials.Length; i++)
            {
                originalColors[i] = instanceMaterials[i].color;
            }
        }
        else
        {
            Debug.LogWarning("Flappyplumber: No se encontro ningun Renderer en los hijos.");
        }
    }

    [System.Obsolete]
    void Update()
    {
        if (isDead) return;

        bool clicked = Mouse.current != null && Mouse.current.leftButton.wasPressedThisFrame;
        bool spacePressed = Keyboard.current != null && Keyboard.current.spaceKey.wasPressedThisFrame;

        if (clicked || spacePressed)
            rb2D.linearVelocity = Vector2.up * velocity;

        transform.rotation = Quaternion.Euler(0, 0, rb2D.velocity.y * rotationSpeed * Time.deltaTime * 100);
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        HandleDeath();
    }

    private void HandleDeath()
    {
        if (isDead) return;
        isDead = true;

        if (modelRenderer != null)
            StartCoroutine(PulseColorBeforeGameOver());

        if (audioSource != null)
            audioSource.Play();

        StartCoroutine(HandleGameOver());
    }

    private IEnumerator PulseColorBeforeGameOver()
    {
        float elapsed = 0f;

        while (elapsed < gameOverDelay)
        {
            float wave = (Mathf.Sin(elapsed * pulseSpeed) + 1f) * 0.5f;

            // Aplica el pulso a TODOS los materiales de Mario
            for (int i = 0; i < instanceMaterials.Length; i++)
            {
                instanceMaterials[i].color = Color.Lerp(originalColors[i], collisionPulseColor, wave);
            }

            elapsed += Time.deltaTime;
            yield return null;
        }

        // Restaura todos los colores originales
        for (int i = 0; i < instanceMaterials.Length; i++)
        {
            instanceMaterials[i].color = originalColors[i];
        }
    }

    private IEnumerator HandleGameOver()
    {
        yield return new WaitForSeconds(gameOverDelay);

        GameManager gameManager = FindAnyObjectByType<GameManager>();
        if (gameManager != null)
            gameManager.GameOver();
    }
}