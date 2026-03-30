function openModal() {
  const modal = document.getElementById("postModal");
  if (modal) modal.style.display = "flex";
}

function closeModal() {
  const modal = document.getElementById("postModal");
  if (modal) modal.style.display = "none";
}

function toggleLike(element) {
  if (!element) return;

  if (element.classList.contains("liked")) {
    element.classList.remove("liked");
    element.innerText = "♡";
  } else {
    element.classList.add("liked");
    element.innerText = "❤️";
  }
}

function deletePost(btn) {
  const post = btn.closest(".post-card");
  if (!post) return;

  if (post.classList.contains("dynamic-post")) {
    const textElement = post.querySelector(".post-text");
    const text = textElement ? textElement.innerText : "";

    let posts = JSON.parse(localStorage.getItem("posts")) || [];
    const index = posts.indexOf(text);
    if (index !== -1) {
      posts.splice(index, 1);
      localStorage.setItem("posts", JSON.stringify(posts));
    }
  }

  post.remove();
}

function publishPost() {
  const input = document.getElementById("postInput");
  if (!input) return;

  const text = input.value.trim();

  if (text === "") {
    alert("Écris quelque chose !");
    return;
  }

  let posts = JSON.parse(localStorage.getItem("posts")) || [];
  posts.unshift(text);
  localStorage.setItem("posts", JSON.stringify(posts));

  displayPosts();
  input.value = "";
  closeModal();
}

function displayPosts() {
  const campusNews = document.querySelector(".campus-news");
  if (!campusNews) return; // important : seulement sur la page accueil

  document.querySelectorAll(".dynamic-post").forEach((post) => post.remove());

  const posts = JSON.parse(localStorage.getItem("posts")) || [];

  posts.slice().reverse().forEach((text) => {
    const newPost = document.createElement("article");
    newPost.className = "post-card dynamic-post";

    newPost.innerHTML = `
      <div class="post-top">
        <div class="user">
          <div class="avatar">Y</div>
          <div>
            <h3>Toi</h3>
            <p>Maintenant</p>
          </div>
        </div>
        <button class="dots" onclick="deletePost(this)">🗑</button>
      </div>

      <p class="post-text">${text}</p>

      <div class="post-actions">
        <span onclick="toggleLike(this)">♡</span>
        <span>💬</span>
        <span>↗</span>
      </div>
    `;

    campusNews.insertAdjacentElement("afterend", newPost);
  });
}

function editProfile() {
  const nameElement = document.getElementById("profileName");
  const bioElement = document.getElementById("profileBio");

  if (!nameElement || !bioElement) return;

  const currentName = nameElement.innerText;
  const currentBio = bioElement.innerText;

  const newName = prompt("Nouveau nom :", currentName);
  const newBio = prompt("Nouvelle bio :", currentBio);

  if (newName !== null && newName.trim() !== "") {
    nameElement.innerText = newName.trim();
    localStorage.setItem("profileName", newName.trim());
  }

  if (newBio !== null && newBio.trim() !== "") {
    bioElement.innerText = newBio.trim();
    localStorage.setItem("profileBio", newBio.trim());
  }
}

function loadProfile() {
  const nameElement = document.getElementById("profileName");
  const bioElement = document.getElementById("profileBio");

  const savedName = localStorage.getItem("profileName");
  const savedBio = localStorage.getItem("profileBio");

  if (nameElement && savedName) nameElement.innerText = savedName;
  if (bioElement && savedBio) bioElement.innerText = savedBio;
}

function sendMessage(event) {
  event.preventDefault();

  const input = document.getElementById("messageInput");
  const messagesContainer = document.getElementById("chatMessages");

  if (!input || !messagesContainer) return;

  const text = input.value.trim();
  if (text === "") return;

  const newMessage = document.createElement("div");
  newMessage.className = "message-bubble sent";
  newMessage.innerText = text;

  messagesContainer.appendChild(newMessage);
  input.value = "";
  messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

function sendBotMessage(event) {
  event.preventDefault();

  const input = document.getElementById("userInput");
  const chat = document.getElementById("chatContainer");

  if (!input || !chat) return;

  const text = input.value.trim();
  if (text === "") return;

  const userMsg = document.createElement("div");
  userMsg.className = "user-message";
  userMsg.innerText = text;
  chat.appendChild(userMsg);

  const botMsg = document.createElement("div");
  botMsg.className = "bot-message";

  const lowerText = text.toLowerCase();

  if (lowerText.includes("profil")) {
    botMsg.innerText = "Tu peux améliorer ton profil en ajoutant tes compétences, ta bio et tes projets.";
  } else if (lowerText.includes("projet")) {
    botMsg.innerText = "Idée de projet : une application de collaboration entre étudiants selon leurs compétences.";
  } else if (lowerText.includes("alternance")) {
    botMsg.innerText = "Consulte Ymatch et complète ton profil pour mieux te démarquer.";
  } else if (lowerText.includes("design")) {
    botMsg.innerText = "Travaille une interface claire, moderne et cohérente pour améliorer l’expérience utilisateur.";
  } else {
    botMsg.innerText = "Bonne question 👍 Je peux t’aider sur le profil, les projets, le design et les opportunités.";
  }

  chat.appendChild(botMsg);
  input.value = "";
  chat.scrollTop = chat.scrollHeight;
}

function connectUser(btn) {
  btn.innerText = "Connecté";
  btn.disabled = true;
}

function openProject(title, desc) {
  alert(title + "\n\n" + desc);
}

const searchData = [
  { type: "etudiant", title: "Sofia Benali", desc: "UI Designer • Recherche projet" },
  { type: "etudiant", title: "Lina Morel", desc: "Dev Front-end • React" },
  { type: "etudiant", title: "Yassine Karim", desc: "Étudiant B2 • Front-end • UX/UI" },
  { type: "projet", title: "Projet Mobile App", desc: "Recherche développeur JS" },
  { type: "projet", title: "Projet YConnect", desc: "Application sociale pour étudiants Ynov" },
  { type: "projet", title: "Projet Campus", desc: "Projet étudiant autour de la vie Ynov" }
];

function renderSearchResults(filter = "tous", keyword = "") {
  const resultsContainer = document.getElementById("resultsContainer");
  if (!resultsContainer) return;

  const lowerKeyword = keyword.toLowerCase().trim();

  const filtered = searchData.filter((item) => {
    const matchesType = filter === "tous" || item.type === filter;
    const matchesKeyword =
      lowerKeyword === "" ||
      item.title.toLowerCase().includes(lowerKeyword) ||
      item.desc.toLowerCase().includes(lowerKeyword);

    return matchesType && matchesKeyword;
  });

  resultsContainer.innerHTML = "";

  if (filtered.length === 0) {
    resultsContainer.innerHTML = `
      <div class="result-card">
        <div class="result-info">
          <h3>Aucun résultat</h3>
          <p>Essaie avec un autre mot-clé.</p>
        </div>
      </div>
    `;
    return;
  }

  filtered.forEach((item) => {
    const firstLetter = item.title.charAt(0).toUpperCase();
    const buttonText = item.type === "etudiant" ? "+ Connect" : "Voir";

    const buttonAction =
      item.type === "etudiant"
        ? `onclick="connectUser(this)"`
        : `onclick="openProject('${item.title}', '${item.desc}')"`; 

    const card = document.createElement("div");
    card.className = "result-card";
    card.innerHTML = `
      <div class="result-avatar">${firstLetter}</div>
      <div class="result-info">
        <h3>${item.title}</h3>
        <p>${item.desc}</p>
      </div>
      <button class="connect-btn" ${buttonAction}>${buttonText}</button>
    `;
    resultsContainer.appendChild(card);
  });
}

function setupSearchPage() {
  const input = document.getElementById("searchInput");
  const filterButtons = document.querySelectorAll(".filter-btn");
  const resultsContainer = document.getElementById("resultsContainer");

  if (!input || !resultsContainer || filterButtons.length === 0) return;

  let activeFilter = "tous";

  renderSearchResults(activeFilter, "");

  input.addEventListener("input", function () {
    renderSearchResults(activeFilter, input.value);
  });

  filterButtons.forEach((btn) => {
    btn.addEventListener("click", function () {
      filterButtons.forEach((b) => b.classList.remove("active"));
      this.classList.add("active");
      activeFilter = this.dataset.filter;
      renderSearchResults(activeFilter, input.value);
    });
  });
}

function showAllNews() {
  alert(
    "News Ynov :\n\n- Challenge 48h demain à 14h\n- Nouvelles offres Ymatch\n- Événement BDE vendredi\n- Tournoi BDS la semaine prochaine"
  );
}

window.onload = function () {
  displayPosts();
  loadProfile();
  setupSearchPage();
};
function register() {
  const firstName = document.getElementById("registerFirstName")?.value.trim();
  const lastName = document.getElementById("registerLastName")?.value.trim();
  const userClass = document.getElementById("registerClass")?.value.trim();
  const email = document.getElementById("registerEmail")?.value.trim();
  const password = document.getElementById("registerPassword")?.value.trim();

  if (!firstName || !lastName || !userClass || !email || !password) {
    alert("Remplis tous les champs !");
    return;
  }

  localStorage.setItem("userFirstName", firstName);
  localStorage.setItem("userLastName", lastName);
  localStorage.setItem("userClass", userClass);
  localStorage.setItem("userEmail", email);
  localStorage.setItem("userPassword", password);

  alert("Compte créé avec succès !");
  window.location.href = "login.html";
}

function login() {
  const email = document.getElementById("loginEmail")?.value.trim();
  const password = document.getElementById("loginPassword")?.value.trim();

  const savedEmail = localStorage.getItem("userEmail");
  const savedPassword = localStorage.getItem("userPassword");

  console.log("email saisi :", email);
  console.log("password saisi :", password);
  console.log("email enregistré :", savedEmail);
  console.log("password enregistré :", savedPassword);

  if (!email || !password) {
    alert("Remplis tous les champs !");
    return;
  }

  if (email === savedEmail && password === savedPassword) {
    alert("Connexion réussie !");
    window.location.href = "index.html";
  } else {
    alert("Email ou mot de passe incorrect");
  }


  localStorage.setItem("userFirstName", firstName);
  localStorage.setItem("userLastName", lastName);
  localStorage.setItem("userClass", userClass);
  localStorage.setItem("userEmail", email);
  localStorage.setItem("userPassword", password);

  alert("Compte créé avec succès !");
  window.location.href = "login.html";
}

function logout() {
  localStorage.removeItem("userEmail");
  localStorage.removeItem("userPassword");

  alert("Déconnecté !");
  window.location.href = "login.html";
}
function checkAuth() {
  const email = localStorage.getItem("userEmail");

  if (!email) {
    window.location.href = "login.html";
  }
}
function applyJob(btn) {
  btn.innerText = "Candidature envoyée";
  btn.disabled = true;
}