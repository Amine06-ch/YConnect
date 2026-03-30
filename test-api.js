require('dotenv').config();

async function testConnexion() {
    const key = process.env.GEMINI_API_KEY;
    
    // Utilisation du nom exact : gemini-3-flash-preview
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=${key}`;

    try {
        const response = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                contents: [{ 
                    parts: [{ text: "Réponds par 'Connexion Réseau Social OK' si tu reçois ce message." }] 
                }]
            })
        });

        const data = await response.json();

        if (data.error) {
            console.error("❌ Erreur de l'API :");
            console.log("Message :", data.error.message);
            console.log("Statut :", data.error.status);
        } else if (data.candidates && data.candidates[0].content) {
            console.log("✅ ENFIN ! Le modèle Gemini 3 répond.");
            console.log("Réponse de l'IA :", data.candidates[0].content.parts[0].text);
        } else {
            console.log("Réponse reçue mais vide :", JSON.stringify(data, null, 2));
        }
    } catch (error) {
        console.error("❌ Erreur technique :", error);
    }
}

testConnexion();