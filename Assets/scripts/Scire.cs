using TMPro;
using UnityEngine;

public class Scire : MonoBehaviour
{   
    public TextMeshProUGUI scoreText;
    public TextMeshProUGUI bestScoreText;

    private int score = 0;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        scoreText.text = score.ToString();
        bestScoreText.text = PlayerPrefs.GetInt("BestScore", 0).ToString();
    }

    // Update is called once per frame

    public void UpdateBestScore()
    {

        if (score > PlayerPrefs.GetInt("BestScore", 0))
        {
            PlayerPrefs.SetInt("BestScore", score);
            bestScoreText.text = score.ToString();
        }
    }

    public void updateScore()
    {
        score++;
        scoreText.text = score.ToString();
        UpdateBestScore();
    }
}
