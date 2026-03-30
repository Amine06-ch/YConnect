require('dotenv').config();

async function appelerIA(texteUtilisateur) {
    // On récupère la clé depuis le fichier .env pour la sécurité
    const apiKey = process.env.GEMINI_API_KEY;
    const url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent";

    try {
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-goog-api-key': apiKey // Ta clé est transmise ici de façon sécurisée
            },
            body: JSON.stringify({
                "contents": [
                    {
                        "parts": [
                            {
                                "text": texteUtilisateur
                            }
                        ]
                    }
                ]
            })
        });

        const data = await response.json();
        
        // On extrait le texte pour tes collègues
        return data.candidates[0].content.parts[0].text;

    } catch (error) {
        console.error("Erreur API :", error);
        return "Désolé, l'IA est indisponible.";
    }
}

// Petit test pour vérifier que ça marche
appelerIA("Explique l'IA en quelques mots")
    .then(reponse => console.log("Réponse :", reponse));