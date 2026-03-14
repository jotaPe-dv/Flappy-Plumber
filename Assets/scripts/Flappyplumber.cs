using UnityEngine;
using UnityEngine.InputSystem;
using System.Collections;

public class Flappyplumber : MonoBehaviour
{
    public float velocity = 2;
    public Rigidbody2D rb2D;

    public float rotationSpeed = 25;

    public AudioSource audioSource;
    public Material collisionPulseMaterial;
    public float gameOverDelay = 0.6f;
    public Color collisionPulseColor = new Color(1f, 0.2f, 0.2f, 1f);
    public float pulseSpeed = 18f;

    private SpriteRenderer spriteRenderer;
    private bool isDead;
    private Color originalColor;


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        rb2D = GetComponent<Rigidbody2D>();
        spriteRenderer = GetComponent<SpriteRenderer>();
        if (spriteRenderer == null)
        {
            spriteRenderer = GetComponentInChildren<SpriteRenderer>();
        }

        if (spriteRenderer != null)
        {
            originalColor = spriteRenderer.color;
        }
    }

    // Update is called once per frame
    [System.Obsolete]
    void Update()
    {
        if (isDead)
        {
            return;
        }

        bool clicked = Mouse.current != null && Mouse.current.leftButton.wasPressedThisFrame;
        bool spacePressed = Keyboard.current != null && Keyboard.current.spaceKey.wasPressedThisFrame;

        if (clicked || spacePressed)
        {
            rb2D.linearVelocity = Vector2.up * velocity;
        }
        
        transform.rotation = Quaternion.Euler(0, 0, rb2D.velocity.y * rotationSpeed * Time.deltaTime * 100);

    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        HandleDeath();
    }

    private void HandleDeath()
    {
        if (isDead)
        {
            return;
        }

        isDead = true;

        if (collisionPulseMaterial != null && spriteRenderer != null)
        {
            spriteRenderer.material = collisionPulseMaterial;
        }

        if (spriteRenderer != null)
        {
            StartCoroutine(PulseColorBeforeGameOver());
        }

        if (audioSource != null)
        {
            audioSource.Play();
        }

        StartCoroutine(HandleGameOver());
    }

    private IEnumerator PulseColorBeforeGameOver()
    {
        float elapsed = 0f;

        while (elapsed < gameOverDelay)
        {
            float wave = (Mathf.Sin(elapsed * pulseSpeed) + 1f) * 0.5f;
            spriteRenderer.color = Color.Lerp(originalColor, collisionPulseColor, wave);

            elapsed += Time.deltaTime;
            yield return null;
        }
    }

    private IEnumerator HandleGameOver()
    {
        yield return new WaitForSeconds(gameOverDelay);

        GameManager gameManager = FindAnyObjectByType<GameManager>();
        if (gameManager != null)
        {
            gameManager.GameOver();
        }
    }
}
