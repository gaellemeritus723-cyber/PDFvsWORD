<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Convertisseur Express | Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.4.2/mammoth.browser.min.js"></script>
    <style>
        .action-buttons { display: none; margin-top: 15px; gap: 10px; flex-wrap: wrap; }
        .btn-share { padding: 8px 12px; border-radius: 6px; border: none; cursor: pointer; color: white; font-weight: 600; text-decoration: none; font-size: 0.85rem; }
        .whatsapp { background: #25D366; }
        .telegram { background: #0088cc; }
        .download { background: #4f46e5; }
    </style>
</head>
<body>
    <div class="split-view">
        <aside class="controls-section">
            <h2>Convertisseur Express</h2>
            <form id="uploadForm" enctype="multipart/form-data">
                <div class="form-group">
                    <label>Choisir votre fichier :</label>
                    <input type="file" name="fileInput" id="fileInput" required onchange="gererApercuAvant()" />
                </div>
                <div class="form-group">
                    <label>Format cible</label>
                    <select name="formatCible" id="formatCible">
                        <option value="pdf">Vers PDF</option>
                        <option value="docx">Vers Word</option>
                    </select>
                </div>
                <button type="submit" class="btn-primary" id="btnConvertir">Convertir maintenant</button>
            </form>
                <div id="loaderContainer" class="loader-container" style="display: none; margin-top: 20px;">
                    <div class="spinner"></div>
                    <p id="statusText">Conversion en cours...</p>
                    <div class="progress-bar-bg">
                        <div id="progressBar" class="progress-bar-fill" style="width: 0%;"></div>
                    </div>
                </div>

                <div id="shareSection" class="action-buttons">
                    <p style="width: 100%; font-weight: bold; margin-bottom: 5px;">Partager le résultat :</p>
                    <a href="#" id="dlLink" class="btn-share download" download>📥 Télécharger</a>
                    <a href="#" id="waLink" class="btn-share whatsapp" target="_blank">💬 WhatsApp</a>
                    <a href="#" id="tgLink" class="btn-share telegram" target="_blank">✈️ Telegram</a>
                </div>
            </aside>

            <main class="preview-section">
                <header class="preview-header"><span id="nomFichier">Aperçu</span></header>
                <div id="previewBody" class="preview-body">
                    <div class="empty-state"><p>L'aperçu apparaîtra ici.</p></div>
                </div>
            </main>
        </div>
    <script>
        
        // Envoi AJAX pour ne pas recharger la page
        document.getElementById('uploadForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const btn = document.getElementById('btnConvertir');
            const loader = document.getElementById('loaderContainer');
            const bar = document.getElementById('progressBar');

            loader.style.display = 'block';
            btn.disabled = true;

            fetch('ConversionServlet', { method: 'POST', body: formData })
            .then(response => response.blob())
            .then(blob => {
                const url = URL.createObjectURL(blob);
                const format = document.getElementById('formatCible').value;
                
                // 1. Mise à jour de l'aperçu avec le fichier converti
                if (format === "pdf") {
                    document.getElementById('previewBody').innerHTML = `<iframe src="${url}" width="100%" height="100%"></iframe>`;
                } else {
                    document.getElementById('previewBody').innerHTML = `<div class="empty-state">✅ Conversion terminée !</div>`;
                }

                // 2. Configuration des boutons de partage et téléchargement
                document.getElementById('shareSection').style.display = 'flex';
                document.getElementById('dlLink').href = url;
                
                // Note : Pour WhatsApp/Telegram, on partage généralement un lien. 
                // Ici, comme le fichier est local, on propose de partager le texte de succès.
                const shareMsg = encodeURIComponent("J'ai converti mon document avec succès !");
                document.getElementById('waLink').href = `https://wa.me/?text=${shareMsg}`;
                document.getElementById('tgLink').href = `https://t.me/share/url?url=${window.location.href}&text=${shareMsg}`;

                loader.style.display = 'none';
                btn.disabled = false;
                bar.style.width = "100%";
            })
            .catch(err => alert("Erreur : " + err));
        });
        </script>

</body>
</html>