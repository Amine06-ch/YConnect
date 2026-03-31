const API_BASE_URL = "http://localhost:5000/api";

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

async function deletePost(id) {
  const token = localStorage.getItem("token");

  if (!token) {
    alert("Tu dois être connecté !");
    return;
  }

  try {
    const res = await fetch(`${API_BASE_URL}/posts/${id}`, {
      method: "DELETE",
      headers: {
        Authorization: "Bearer " + token,
      },
    });

    const data = await res.json();

    if (!res.ok || !data.success) {
      alert(data.message || "Erreur suppression");
      return;
    }

    displayPosts();
  } catch (error) {
    console.error("Erreur suppression post:", error);
    alert("Impossible de supprimer le post.");
  }
}

async function publishPost() {
  const input = document.getElementById("postInput");
  if (!input) return;

  const text = input.value.trim();

  if (text === "") {
    alert("Écris quelque chose !");
    return;
  }

  const token = localStorage.getItem("token");

  if (!token) {
    alert("Tu dois être connecté !");
    return;
  }

  try {
    const res = await fetch(`${API_BASE_URL}/posts`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + token,
      },
      body: JSON.stringify({
        content: text,
      }),
    });

    const data = await res.json();

    if (!res.ok || !data.success) {
      alert(data.message || "Erreur création post");
      return;
    }

    input.value = "";
    closeModal();
    displayPosts();
  } catch (error) {
    console.error("Erreur création post:", error);
    alert("Impossible de créer le post.");
  }
}

async function displayPosts() {
  const campusNews = document.querySelector(".campus-news");
  if (!campusNews) return;

  document.querySelectorAll(".dynamic-post").forEach((post) => post.remove());

  try {
    const res = await fetch(`${API_BASE_URL}/posts`);
    const data = await res.json();

    if (!res.ok || !data.success) return;

    const currentUser = JSON.parse(localStorage.getItem("user") || "{}");

    data.data.forEach((post) => {
      const firstName = post.author?.firstName || "User";
      const lastName = post.author?.lastName || "";
      const initial = firstName.charAt(0).toUpperCase();
      const canDelete = currentUser.id === post.author?.id;

      const newPost = document.createElement("article");
      newPost.className = "post-card dynamic-post";

      newPost.innerHTML = `
        <div class="post-top">
          <div class="user">
            <div class="avatar">${initial}</div>
            <div>
              <h3>${firstName} ${lastName}</h3>
              <p>${new Date(post.createdAt).toLocaleString()}</p>
            </div>
          </div>
          ${canDelete ? `<button class="dots" onclick="deletePost(${post.id})">🗑</button>` : ""}
        </div>

        <p class="post-text">${post.content}</p>

        <div class="post-actions">
          <span onclick="toggleLike(this)">♡</span>
          <span>💬</span>
          <span>↗</span>
        </div>
      `;

      campusNews.insertAdjacentElement("afterend", newPost);
    });
  } catch (error) {
    console.error("Erreur chargement posts:", error);
  }
}

async function editProfile() {
  const token = localStorage.getItem("token");
  if (!token) {
    alert("Tu dois être connecté.");
    return;
  }

  const currentUser = JSON.parse(localStorage.getItem("user") || "{}");

  const firstName = prompt("Prénom :", currentUser.firstName || "Ynov");
  if (firstName === null) return;

  const lastName = prompt("Nom :", currentUser.lastName || "Student");
  if (lastName === null) return;

  const bio = prompt(
    "Nouvelle bio :",
    currentUser.bio || "Décris ton profil..."
  );
  if (bio === null) return;

  const skills = prompt(
    "Compétences (séparées par des virgules) :",
    currentUser.skills || "HTML, CSS, JavaScript"
  );
  if (skills === null) return;

  try {
    const res = await fetch(`${API_BASE_URL}/users/me`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + token,
      },
      body: JSON.stringify({
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        bio: bio.trim(),
        skills: skills.trim(),
      }),
    });

    const data = await res.json();

    if (!res.ok || !data.success) {
      alert(data.message || "Erreur mise à jour profil");
      return;
    }

    localStorage.setItem("user", JSON.stringify(data.data));
    alert("Profil mis à jour !");
    loadProfile();
  } catch (error) {
    console.error("Erreur update profil:", error);
    alert("Impossible de mettre à jour le profil.");
  }
}

async function loadProfile() {
  const token = localStorage.getItem("token");
  if (!token) return;

  const nameElement = document.getElementById("profileName");
  const bioElement = document.getElementById("profileBio");
  const roleElement = document.querySelector(".profile-role");
  const skillsContainer = document.querySelector(".skills-list");
  const profileBannerTitle = document.querySelector(".profile-banner h2");
  const profileBannerText = document.querySelector(".profile-banner p");

  try {
    const res = await fetch(`${API_BASE_URL}/users/me`, {
      headers: {
        Authorization: "Bearer " + token,
      },
    });

    const data = await res.json();

    if (!res.ok || !data.success || !data.data) return;

    const user = data.data;
    const fullName = `${user.firstName || ""} ${user.lastName || ""}`.trim();
    const bio = user.bio || "Aucune bio pour le moment.";
    const skills = user.skills || "";

    if (nameElement) nameElement.innerText = fullName || "Utilisateur";
    if (bioElement) bioElement.innerText = bio;
    if (roleElement) roleElement.innerText = `${user.email}`;
    if (profileBannerTitle) {
      profileBannerTitle.innerText = `Bienvenue, ${user.firstName || "Ynov"}`;
    }
    if (profileBannerText) {
      profileBannerText.innerText = skills || "Ajoute tes compétences";
    }

    if (skillsContainer) {
      skillsContainer.innerHTML = "";

      const skillsArray = skills
        .split(",")
        .map((skill) => skill.trim())
        .filter((skill) => skill.length > 0);

      if (skillsArray.length === 0) {
        skillsContainer.innerHTML = `<span class="skill-pill">Aucune compétence</span>`;
      } else {
        skillsArray.forEach((skill) => {
          const span = document.createElement("span");
          span.className = "skill-pill";
          span.innerText = skill;
          skillsContainer.appendChild(span);
        });
      }
    }

    localStorage.setItem("user", JSON.stringify(user));
  } catch (error) {
    console.error("Erreur profil:", error);
  }
}

async function loadConversations() {
  const token = localStorage.getItem("token");
  const list = document.querySelector(".messages-list-card");

  if (!token || !list) return;

  try {
    const res = await fetch(`${API_BASE_URL}/messages/conversations`, {
      headers: {
        Authorization: "Bearer " + token,
      },
    });

    const data = await res.json();

    if (!res.ok || !data.success) return;

    const oldItems = list.querySelectorAll(".conversation-item");
    oldItems.forEach((item) => item.remove());

    data.data.forEach((conversation) => {
      const user = conversation.user;
      const initial = user.firstName?.charAt(0)?.toUpperCase() || "U";

      const div = document.createElement("div");
      div.className = "conversation-item";
      div.onclick = () =>
        loadConversation(user.id, `${user.firstName} ${user.lastName}`);

      div.innerHTML = `
        <div class="conversation-avatar">${initial}</div>
        <div class="conversation-info">
          <h3>${user.firstName} ${user.lastName}</h3>
          <p>${conversation.lastMessage}</p>
        </div>
        <span class="conversation-time">${new Date(conversation.createdAt).toLocaleTimeString()}</span>
      `;

      list.appendChild(div);
    });
  } catch (error) {
    console.error("Erreur conversations:", error);
  }
}

async function loadConversation(userId, fullName = "Conversation") {
  const token = localStorage.getItem("token");
  const messagesContainer = document.getElementById("chatMessages");
  const chatHeaderName = document.querySelector(".chat-user h3");

  if (!token || !messagesContainer) return;

  try {
    const res = await fetch(`${API_BASE_URL}/messages/${userId}`, {
      headers: {
        Authorization: "Bearer " + token,
      },
    });

    const data = await res.json();

    if (!res.ok || !data.success) return;

    if (chatHeaderName) {
      chatHeaderName.innerText = fullName;
    }

    messagesContainer.innerHTML = "";

    const currentUser = JSON.parse(localStorage.getItem("user") || "{}");

    data.data.forEach((message) => {
      const div = document.createElement("div");
      div.className =
        message.senderId === currentUser.id
          ? "message-bubble sent"
          : "message-bubble received";

      div.innerText = message.content;
      messagesContainer.appendChild(div);
    });

    messagesContainer.scrollTop = messagesContainer.scrollHeight;
    localStorage.setItem("activeConversationUserId", String(userId));
  } catch (error) {
    console.error("Erreur conversation:", error);
  }
}

async function sendMessage(event) {
  event.preventDefault();

  const input = document.getElementById("messageInput");
  const token = localStorage.getItem("token");
  const receiverId = localStorage.getItem("activeConversationUserId");

  if (!input || !token || !receiverId) return;

  const text = input.value.trim();
  if (text === "") return;

  try {
    const res = await fetch(`${API_BASE_URL}/messages`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + token,
      },
      body: JSON.stringify({
        receiverId: Number(receiverId),
        content: text,
      }),
    });

    const data = await res.json();

    if (!res.ok || !data.success) {
      alert(data.message || "Erreur envoi message");
      return;
    }

    input.value = "";
    loadConversation(
      Number(receiverId),
      document.querySelector(".chat-user h3")?.innerText || "Conversation"
    );
    loadConversations();
  } catch (error) {
    console.error("Erreur envoi message:", error);
  }
}

async function sendBotMessage(event) {
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

  input.value = "";

  try {
    const res = await fetch(`${API_BASE_URL}/ai/chat`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: text,
      }),
    });

    const data = await res.json();

    const botMsg = document.createElement("div");
    botMsg.className = "bot-message";
    botMsg.innerText =
      data?.success && data?.data?.reply
        ? data.data.reply
        : "Erreur IA, réessaie plus tard.";

    chat.appendChild(botMsg);
    chat.scrollTop = chat.scrollHeight;
  } catch (error) {
    console.error("Erreur bot:", error);

    const botMsg = document.createElement("div");
    botMsg.className = "bot-message";
    botMsg.innerText = "Impossible de contacter l’assistant IA.";
    chat.appendChild(botMsg);
    chat.scrollTop = chat.scrollHeight;
  }
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
  { type: "projet", title: "Projet Campus", desc: "Projet étudiant autour de la vie Ynov" },
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

async function register() {
  const email = document.getElementById("registerEmail")?.value.trim();
  const password = document.getElementById("registerPassword")?.value.trim();

  if (!email || !password) {
    alert("Remplis tous les champs !");
    return;
  }

  try {
    const response = await fetch(`${API_BASE_URL}/auth/register`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, password }),
    });

    const data = await response.json();

    if (!response.ok || !data.success) {
      alert(data.message || "Erreur lors de l'inscription");
      return;
    }

    alert("Compte créé !");
    window.location.href = "login.html";
  } catch (error) {
    console.error("Register error:", error);
    alert("Impossible de contacter le serveur.");
  }
}

async function login() {
  const email = document.getElementById("loginEmail")?.value.trim();
  const password = document.getElementById("loginPassword")?.value.trim();

  if (!email || !password) {
    alert("Remplis tous les champs !");
    return;
  }

  try {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, password }),
    });

    const data = await response.json();

    if (!response.ok || !data.success) {
      alert(data.message || "Email ou mot de passe incorrect");
      return;
    }

    localStorage.setItem("token", data.data.token);
    localStorage.setItem("user", JSON.stringify(data.data.user));

    alert("Connexion réussie !");
    window.location.href = "index.html";
  } catch (error) {
    console.error("Login error:", error);
    alert("Impossible de contacter le serveur.");
  }
}

function logout() {
  localStorage.removeItem("token");
  localStorage.removeItem("user");
  localStorage.removeItem("profileName");
  localStorage.removeItem("profileBio");
  localStorage.removeItem("activeConversationUserId");

  alert("Déconnecté !");
  window.location.href = "login.html";
}

function checkAuth() {
  const token = localStorage.getItem("token");
  const publicPages = ["login.html", "register.html"];
  const currentPage = window.location.pathname.split("/").pop();

  if (!token && !publicPages.includes(currentPage)) {
    window.location.href = "login.html";
  }
}

function applyJob(btn) {
  btn.innerText = "Candidature envoyée";
  btn.disabled = true;
}

window.onload = function () {
  checkAuth();
  displayPosts();
  loadProfile();
  setupSearchPage();
  loadConversations();
};