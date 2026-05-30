import matplotlib.pyplot as plt

# ================================
# Datos experimentales P3
# ================================

top_k = [50, 100, 200]

datos = {
    "10 mil registros": {
        "con_indice": [57.938, 63.821, 673.102],
        "sin_indice": [9057.852, 9990.613, 9907.680]
    },
    "20 mil registros": {
        "con_indice": [704.686, 293.596, 227.423],
        "sin_indice": [20074.397, 22524.335, 23287.751]
    },
    "30 mil registros": {
        "con_indice": [653.076, 582.036, 626.550],
        "sin_indice": [24117.433, 24132.071, 23440.400]
    }
}

# ================================
# Generar una gráfica por tamaño
# ================================

for titulo, valores in datos.items():
    plt.figure(figsize=(9, 5))

    plt.plot(top_k, valores["sin_indice"], marker='o', label='Sin índice')
    plt.plot(top_k, valores["con_indice"], marker='o', label='Con índice GIN')

    plt.title(f'Comparación de tiempos - {titulo}')
    plt.xlabel('Top-k mejores resultados')
    plt.ylabel('Tiempo de ejecución (ms)')
    plt.xticks(top_k)
    plt.grid(True, linestyle='--', linewidth=0.5)
    plt.legend()

    plt.tight_layout()
    plt.show()