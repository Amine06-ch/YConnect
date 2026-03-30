require('dotenv').config();

async function modererMessage(texteUtilisateur) {
    const key = process.env.GEMINI_API_KEY;
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=${key}`;

    // On prépare une consigne très précise pour l'IA
    const consigneModération = `
        Tu es un modérateur de réseau social d'étudiants. 
        Analyse le message suivant : "${texteUtilisateur}".
        Si le message contient des insultes, de la haine ou est déplacé, réponds uniquement par le mot "REFUSE".
        Sinon, réponds uniquement par le mot "VALIDE".
    `;

    try {
        const response = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                contents: [{ parts: [{ text: consigneModération }] }]
            })
        });

        const data = await response.json();
        const decision = data.candidates[0].content.parts[0].text.trim();
        
        return decision; // Renverra "VALIDE" ou "REFUSE"
    } catch (error) {
        console.error("Erreur Modération :", error);
        return "ERREUR"; 
    }
}

// TEST : Essaie avec un message gentil et un message méchant
modererMessage("Salut tout le monde, j'adore coder en JS !")
    .then(res => console.log("Résultat test 1 (gentil) :", res));

modererMessage("Vous êtes tous des nuls, je déteste ce projet !")
    .then(res => console.log("Résultat test 2 (méchant) :", res));

module.exports = { modererMessage };