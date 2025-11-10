# MPPT — P&O vs MLP (dados JRC + perfis sintéticos)

> Repositório de suporte ao artigo: **Rastreamento de Máxima Potência em Sistemas FV: comparação justa entre P&O e MLP com dados reais (JRC) e perfis dinâmicos sintéticos**.

## 🚀 Objetivo
Comparar um controlador MPPT clássico **Perturba‑e‑Observa (P&O)** com um regressor **MLP** que prediz \(V_{mpp}\) a partir de irradiância \(G\) e temperatura do ar \(T_a\), usando:
- **Dados reais** do PVGIS/JRC (Porto, PT), e
- **Perfil sintético** com degraus de irradiância para testes dinâmicos.

## 🧱 Estrutura sugerida do repositório
```
.
├── data/
│   ├── JRC/                 # séries de G e Ta (CSV, limpos)
│   ├── synthetic/           # perfis sintéticos gerados pelo script
│   └── raw/                 # dados originais antes da limpeza (opcional)
├── notebooks/
│   └── mppt.ipynb           # pipeline completo: modelo FV, P&O, MLP e avaliação
├── src/
│   ├── pv_model.py          # modelo de diodo único e utilitários numéricos
│   ├── mlp.py               # treino/inferência do MLP (scikit-learn/PyTorch)
│   ├── po_controller.py     # implementação do P&O (fixo/adaptativo + filtros)
│   ├── metrics.py           # eficiência de energia, MAE, RMSE, etc.
│   └── figures.py           # geração padronizada de figuras (PDF/SVG)
├── results/
│   ├── tables/              # Tabela 1 (JRC), Tabela 2 (sintético)
│   └── figures/             # figuras exportadas em vetor
├── requirements.txt         # dependências mínimas
├── LICENSE                  # licença (MIT ou CC-BY)
└── README.md                # este arquivo
```

> **Dica:** mantenha resultados reproduzíveis em `results/` gerados por scripts (`Makefile` ou `tox`/`nox`).

## 🔧 Ambiente
Crie um ambiente e instale as dependências mínimas:
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -U pip wheel
pip install -r requirements.txt
```
**requirements.txt (exemplo):**
```
numpy>=1.24
scipy>=1.10
pandas>=2.0
scikit-learn>=1.3
matplotlib>=3.8
jupyter>=1.0
```
> Se optar por **PyTorch** para o MLP: `torch>=2.1` (CPU já basta).

## 📥 Dados
- **JRC/PVGIS:** exporte séries horárias de irradiância no plano e temperatura do ar para *Porto, Portugal* e salve em `data/JRC/`.  
- **Sintético:** o próprio notebook gera `data/synthetic/*.csv` com degraus de \(G\) e oscilação suave de \(T_a\).

Formato esperado (CSV):
```
timestamp, G (W/m^2), Ta (°C)
2023-01-01T00:00:00Z, 0, 12.0
...
```

## 🧠 Metodologia (resumo)
- **Modelo FV:** diodo único; Newton‑Raphson com salvaguardas; cálculo de \(T_c = T_a + 0,03G\); varredura para \(P_{mpp}\).
- **P&O:** passo \(\Delta V\) fixo, versão opcional com passo adaptativo + média móvel.
- **MLP:** (64,32), ReLU, Adam (1e‑3), early stopping; entrada \((G,T_a)\) normalizada; saída \(V_{mpp}\) normalizado.
- **Métricas:** eficiência de energia \(\eta_E\), MAE e RMSE (potência e tensão).

## ▶️ Como rodar
1. Abra `notebooks/mppt.ipynb` e execute as células em ordem **OU** use os scripts em `src/`:
```bash
python -m src.pv_model --export-curves data/synthetic/curves.csv
python -m src.mlp --train data/JRC/porto.csv --out models/mlp.joblib
python -m src.po_controller --in data/synthetic/steps.csv --out results/po_synth.csv
python -m src.metrics --jrc data/JRC/porto.csv --mlp models/mlp.joblib --out results/tables/jrc.csv
python -m src.figures --in results/tables/jrc.csv --out results/figures/
```
2. As figuras são salvas em `results/figures/` (PDF/SVG) e as tabelas em `results/tables/` (CSV).

## 📊 Resultados esperados (exemplo do artigo)
**JRC (Porto, PT):**
- \(\eta_E\): **MLP 99,94%** vs **P&O 48,53%**
- **RMSE\_P (W):** **MLP 0,072** vs **P&O 37,59**
- **RMSE\_V (V):** **MLP 2,18** vs **P&O 12,65**

**Sintético (degraus de G):**
- \(\eta_E\): **MLP ≈100%** vs **P&O 99,84%**
- **RMSE\_P (W):** **MLP 0,008** vs **P&O 0,319**

> Os números podem variar levemente conforme o hardware, semente aleatória e discretização temporal.

## 🔁 Reprodutibilidade
- Fixe a **semente** (por ex. `PYTHONHASHSEED`, `numpy.random.seed`, `torch.manual_seed`).
- Exporte as **figuras em vetor** (PDF/SVG) com eixos/unidades padronizados.
- Publique o pacote (código + dados processados) no **Zenodo** e inclua o **DOI** aqui.

## 📜 Citação sugerida
```
Resende, D. D. G.; Aguiar, A. M.; Dias, I. F.; Santos, M. N.; Barbosa, A. M.; Figueiredo, R. B. 
Rastreamento de Máxima Potência em Sistemas FV: comparação justa entre P&O e MLP com dados reais (JRC) e perfis dinâmicos sintéticos, 2025.
Repositório/DOI: <adicione o DOI ou URL>
```
> Atualize autores/afiliação e inclua o DOI após o depósito.

## 🪪 Licença
Recomendado **MIT** (código) e **CC‑BY‑4.0** (texto/figuras). Ajuste conforme política da revista.

## 📫 Contato
- Autor correspondente: <seu_email@dominio>
- ORCID: <seu_orcid>
- ABENS/SOBRAEP/UFPR: inclua afiliações e financiadores, se houver.
