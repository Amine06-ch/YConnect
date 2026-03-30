function openModal() {
  const modal = document.getElementById("postModal");
  modal.style.display = "flex";
}

function closeModal() {
  const modal = document.getElementById("postModal");
  modal.style.display = "none";
}

function publishPost() {
  const input = document.getElementById("postInput");
  const text = input.value.trim();

  if (text === "") {
    alert("Écris quelque chose !");
    return;
  }

  const feed = document.querySelector(".feed");

  const newPost = document.createElement("article");
  newPost.className = "post-card";

  newPost.innerHTML = `
    <div class="post-top">
      <div class="user">
        <div class="avatar">Y</div>
        <div>
          <h3>Toi</h3>
          <p>Maintenant</p>
        </div>
      </div>
      <button class="dots">•••</button>
    </div>

    <p class="post-text">${text}</p>

    <div class="post-actions">
      <span>♡</span>
      <span>💬</span>
      <span>↗</span>
    </div>
  `;

  feed.prepend(newPost);
  input.value = "";
  closeModal();
}
function sendMessage(event) {
  event.preventDefault();

  const input = document.getElementById("userInput");
  const text = input.value.trim();

  if (text === "") return;

  const chat = document.getElementById("chatContainer");

  // message utilisateur
  const userMsg = document.createElement("div");
  userMsg.className = "user-message";
  userMsg.innerText = text;
  chat.appendChild(userMsg);

  // réponse fake IA
  const botMsg = document.createElement("div");
  botMsg.className = "bot-message";

  if (text.toLowerCase().includes("profil")) {
    botMsg.innerText = "Tu peux améliorer ton profil en ajoutant tes compétences et projets.";
  } else if (text.toLowerCase().includes("projet")) {
    botMsg.innerText = "Idée : créer une app de mise en relation étudiants-développeurs.";
  } else {
    botMsg.innerText = "Bonne question 👍 je te conseille de travailler ton UI et ton projet.";
  }

  chat.appendChild(botMsg);

  input.value = "";
}