
EASY_WORD_0: .db $15, $08, $12, $0F, $06, $11, $1B, $03, $03, $04, $FF // Vispgrädde
EASY_WORD_1: .db $00, $0B, $05, $00, $01, $04, $13, $04, $13, $FF // Alfabetet
EASY_WORD_2: .db $0D, $00, $13, $08, $0E, $0D, $00, $0B, $04, $0D, $02, $18, $0A, $0B, $0E, $0F, $04, $03, $08, $0D, $FF // Nationalencyklopedin
EASY_WORD_3: .db $03, $1B, $06, $06, $03, $09, $14, $11, $FF // Däggdjur
EASY_WORD_4: .db $0E, $11, $03, $05, $1C, $11, $11, $1A, $03, $FF // Ordförråd
EASY_WORD_5: .db $07, $14, $15, $14, $03, $12, $13, $00, $03, $FF // Huvudstad
EASY_WORD_6: .db $03, $1C, $11, $11, $0C, $00, $13, $13, $00, $FF // Dörrmatta
EASY_WORD_7: .db $00, $0F, $00, $FF // Apa
EASY_WORD_8: .db $12, $0A, $08, $03, $0E, $11, $FF // Skidor
EASY_WORD_9: .db $12, $13, $1B, $0B, $0B, $05, $1C, $11, $04, $13, $11, $1B, $03, $00, $11, $04, $FF // Ställföreträdare
EASY_WORD_10: .db $04, $05, $13, $04, $11, $13, $00, $0D, $0A, $04, $FF // Eftertanke
EASY_WORD_11: .db $0C, $04, $03, $03, $04, $0B, $00, $FF // Meddela
EASY_WORD_12: .db $03, $08, $00, $0B, $04, $0A, $13, $FF // Dialekt
EASY_WORD_13: .db $12, $13, $00, $13, $08, $15, $FF // Stativ
EASY_WORD_14: .db $13, $00, $0D, $0A, $12, $0F, $11, $08, $03, $03, $FF // Tankspridd
EASY_WORD_15: .db $0F, $11, $04, $03, $08, $0A, $00, $FF // Predika
EASY_WORD_16: .db $04, $0D, $05, $0E, $11, $0C, $08, $06, $FF // Enformig
EASY_WORD_17: .db $06, $11, $00, $0D, $00, $13, $FF // Granat
EASY_WORD_18: .db $09, $1B, $0D, $0A, $00, $11, $04, $FF // Jänkare
EASY_WORD_19: .db $0A, $0E, $0D, $03, $04, $0D, $12, $00, $13, $0E, $11, $FF // Kondensator
EASY_WORD_20: .db $1C, $15, $04, $11, $13, $18, $06, $04, $0B, $12, $04, $FF // Övertygelse
EASY_WORD_21: .db $04, $0D, $15, $08, $12, $FF // Envis
EASY_WORD_22: .db $00, $13, $13, $08, $13, $18, $03, $FF // Attityd
EASY_WORD_23: .db $08, $0C, $0C, $14, $0D, $05, $1C, $11, $12, $15, $00, $11, $FF // Immunförsvar
EASY_WORD_24: .db $05, $08, $0B, $0E, $12, $0E, $05, $FF // Filosof
EASY_WORD_25: .db $01, $00, $12, $0A, $04, $11, $FF // Basker
EASY_WORD_26: .db $01, $04, $03, $11, $00, $06, $00, $11, $04, $FF // Bedragare
EASY_WORD_27: .db $00, $15, $0B, $1B, $06, $12, $0D, $00, $FF // Avlägsna
EASY_WORD_28: .db $12, $15, $00, $06, $FF // Svag
EASY_WORD_29: .db $15, $00, $11, $08, $00, $13, $08, $0E, $0D, $FF // Variation
EASY_WORD_30: .db $00, $0D, $15, $08, $12, $00, $FF // anvisa
EASY_WORD_31: .db $13, $08, $06, $04, $11, $FF // Tiger

EASY_ALL:	.dw EASY_WORD_0, EASY_WORD_1, EASY_WORD_2, EASY_WORD_3, EASY_WORD_4, EASY_WORD_5, EASY_WORD_6, EASY_WORD_7, EASY_WORD_8, EASY_WORD_9, EASY_WORD_10, EASY_WORD_11
			.dw EASY_WORD_12, EASY_WORD_13, EASY_WORD_14, EASY_WORD_15, EASY_WORD_16, EASY_WORD_17, EASY_WORD_18, EASY_WORD_19, EASY_WORD_20, EASY_WORD_21, EASY_WORD_22
			.dw EASY_WORD_23, EASY_WORD_24, EASY_WORD_25, EASY_WORD_26, EASY_WORD_27, EASY_WORD_28, EASY_WORD_29, EASY_WORD_30, EASY_WORD_31

NORMAL_WORD_0: .db $18, $13, $12, $0F, $1B, $0D, $0D, $08, $0D, $06, $FF // Ytspänning
NORMAL_WORD_1: .db $12, $13, $00, $02, $0A, $FF // Stack
NORMAL_WORD_2: .db $0F, $04, $0A, $00, $11, $04, $FF // Pekare
NORMAL_WORD_3: .db $00, $13, $0C, $04, $0B, $FF // Atmel
NORMAL_WORD_4: .db $0B, $00, $0C, $0F, $00, $FF // Lampa
NORMAL_WORD_5: .db $01, $18, $17, $0E, $11, $FF // Byxor
NORMAL_WORD_6: .db $11, $04, $18, $0A, $00, $15, $08, $0A, $FF // Reykavik
NORMAL_WORD_7: .db $0F, $0E, $12, $13, $0B, $1A, $03, $00, $FF // Postlåda
NORMAL_WORD_8: .db $11, $04, $18, $0A, $00, $15, $08, $0A, $FF // Reykavik
NORMAL_WORD_9: .db $05, $1C, $11, $13, $00, $0B, $FF // Förtal
NORMAL_WORD_10: .db $0A, $0E, $0D, $14, $0D, $06, $00, $03, $1C, $0C, $04, $13, $FF // Konungadömet
NORMAL_WORD_11: .db $0C, $04, $03, $04, $0B, $0B, $1B, $0D, $06, $03, $FF // Medellängd
NORMAL_WORD_12: .db $00, $14, $13, $0E, $06, $11, $00, $05, $FF // Autograf
NORMAL_WORD_13: .db $0A, $14, $0D, $12, $0A, $00, $0F, $FF // Kunskap
NORMAL_WORD_14: .db $12, $18, $0D, $12, $1B, $13, $13, $FF // Synsätt
NORMAL_WORD_15: .db $11, $1B, $13, $13, $15, $08, $12, $FF // Rättvis
NORMAL_WORD_16: .db $11, $1A, $03, $05, $11, $1A, $06, $00, $FF // Rådfråga
NORMAL_WORD_17: .db $05, $0E, $0D, $0E, $0B, $0E, $06, $08, $FF // Fonologi
NORMAL_WORD_18: .db $11, $1B, $03, $12, $0B, $00, $FF // Rädsla
NORMAL_WORD_19: .db $0E, $0D, $1C, $03, $08, $06, $FF // Onödig
NORMAL_WORD_20: .db $00, $15, $15, $08, $0A, $00, $0D, $03, $04, $FF // Avvikande
NORMAL_WORD_21: .db $12, $18, $0D, $0D, $04, $11, $15, $FF // Synnerv
NORMAL_WORD_22: .db $01, $0B, $18, $06, $12, $00, $0C, $FF // Blygsam
NORMAL_WORD_23: .db $0E, $01, $08, $0B, $03, $00, $03, $FF // Obildad
NORMAL_WORD_24: .db $0F, $0E, $11, $13, $08, $0E, $0D, $04, $11, $00, $FF // Portionera
NORMAL_WORD_25: .db $14, $0F, $0F, $0C, $14, $0D, $13, $11, $00, $FF // Uppmuntra
NORMAL_WORD_26: .db $0C, $0E, $11, $00, $0B, $08, $12, $04, $11, $00, $FF // Moralisera
NORMAL_WORD_27: .db $0E, $0A, $14, $0B, $00, $11, $FF // Okular
NORMAL_WORD_28: .db $0E, $00, $0A, $13, $12, $00, $0C, $FF // Oaktsam
NORMAL_WORD_29: .db $05, $14, $0C, $0B, $08, $06, $FF // Fumlig
NORMAL_WORD_30: .db $0C, $00, $14, $12, $0E, $0B, $04, $14, $0C, $FF // Mausoleum
NORMAL_WORD_31: .db $05, $1C, $11, $07, $00, $0D, $03, $FF // Förhand

NORMAL_ALL:	.dw NORMAL_WORD_0, NORMAL_WORD_1, NORMAL_WORD_2, NORMAL_WORD_3, NORMAL_WORD_4, NORMAL_WORD_5, NORMAL_WORD_6, NORMAL_WORD_7, NORMAL_WORD_8, NORMAL_WORD_9, NORMAL_WORD_10
			.dw	NORMAL_WORD_11, NORMAL_WORD_12, NORMAL_WORD_13, NORMAL_WORD_14, NORMAL_WORD_15, NORMAL_WORD_16, NORMAL_WORD_17, NORMAL_WORD_18, NORMAL_WORD_19, NORMAL_WORD_20
			.dw NORMAL_WORD_21, NORMAL_WORD_22, NORMAL_WORD_23, NORMAL_WORD_24, NORMAL_WORD_25, NORMAL_WORD_26, NORMAL_WORD_27, NORMAL_WORD_28, NORMAL_WORD_29, NORMAL_WORD_30, NORMAL_WORD_31

DIFFICULT_WORD_0: .db $18, $17, $00, $FF // Yxa
DIFFICULT_WORD_1: .db $14, $0A, $14, $0B, $04, $0B, $04, $FF // Ukulele
DIFFICULT_WORD_2: .db $19, $18, $06, $0E, $13, $FF // Zygot
DIFFICULT_WORD_3: .db $17, $18, $0B, $0E, $05, $0E, $0D, $FF // Xylofon
DIFFICULT_WORD_4: .db $18, $00, $13, $19, $18, $FF // Yatzy
DIFFICULT_WORD_5: .db $1A, $0B, $FF // Ål
DIFFICULT_WORD_6: .db $0E, $17, $04, $FF // Oxe
DIFFICULT_WORD_7: .db $07, $1B, $12, $13, $FF // Häst
DIFFICULT_WORD_8: .db $13, $00, $17, $08, $FF // Taxi
DIFFICULT_WORD_9: .db $0C, $18, $12, $0A, $0E, $17, $04, $FF // Myskoxe
DIFFICULT_WORD_10: .db $07, $1B, $17, $00, $FF // Häxa
DIFFICULT_WORD_11: .db $12, $18, $0D, $1A, $0B, $FF // Synål
DIFFICULT_WORD_12: .db $0A, $00, $12, $13, $00, $0D, $09, $04, $13, $13, $FF // Kastanjett
DIFFICULT_WORD_13: .db $13, $08, $0B, $0B, $13, $00, $FF // Tillta
DIFFICULT_WORD_14: .db $01, $0E, $06, $12, $0F, $11, $1C, $13, $FF // Bogspröt
DIFFICULT_WORD_15: .db $00, $11, $0B, $00, $FF // Arla
DIFFICULT_WORD_16: .db $0C, $1A, $05, $1A, $FF // Måfå
DIFFICULT_WORD_17: .db $0A, $11, $1B, $0B, $03, $09, $14, $11, $FF // Kräldjur
DIFFICULT_WORD_18: .db $05, $00, $14, $0D, $00, $FF // Fauna
DIFFICULT_WORD_19: .db $12, $10, $14, $00, $12, $07, $FF // Squash
DIFFICULT_WORD_20: .db $16, $00, $11, $12, $19, $00, $16, $00, $FF // Warszawa
DIFFICULT_WORD_21: .db $00, $06, $00, $FF // Aga
DIFFICULT_WORD_22: .db $0F, $1A, $0A, $04, $FF // Påke
DIFFICULT_WORD_23: .db $0F, $11, $08, $12, $0F, $00, $0B, $0B, $FF // Prispall
DIFFICULT_WORD_24: .db $12, $02, $07, $00, $01, $0B, $0E, $0D, $FF // Schablon
DIFFICULT_WORD_25: .db $07, $0E, $11, $11, $08, $01, $04, $0B, $FF // Horribel
DIFFICULT_WORD_26: .db $06, $0E, $11, $06, $0E, $0D, $19, $0E, $0B, $00, $FF // Gorgonzola
DIFFICULT_WORD_27: .db $05, $0E, $0D, $03, $14, $04, $FF // Fondue
DIFFICULT_WORD_28: .db $0F, $14, $11, $08, $13, $00, $0D, $FF // Puritan
DIFFICULT_WORD_29: .db $03, $14, $01, $08, $04, $11, $FF // Dubier
DIFFICULT_WORD_30: .db $01, $0B, $0E, $13, $13, $FF // Blott
DIFFICULT_WORD_31: .db $0D, $08, $12, $02, $07, $00, $03, $FF // Nischad

DIFFICULT_ALL:	.dw DIFFICULT_WORD_0, DIFFICULT_WORD_1, DIFFICULT_WORD_2, DIFFICULT_WORD_3, DIFFICULT_WORD_4, DIFFICULT_WORD_5, DIFFICULT_WORD_6, DIFFICULT_WORD_7, DIFFICULT_WORD_8, DIFFICULT_WORD_9, DIFFICULT_WORD_10, DIFFICULT_WORD_11
				.dw DIFFICULT_WORD_12, DIFFICULT_WORD_13, DIFFICULT_WORD_14, DIFFICULT_WORD_15, DIFFICULT_WORD_16, DIFFICULT_WORD_17, DIFFICULT_WORD_18, DIFFICULT_WORD_19, DIFFICULT_WORD_20, DIFFICULT_WORD_21, DIFFICULT_WORD_22, DIFFICULT_WORD_23
				.dw DIFFICULT_WORD_24, DIFFICULT_WORD_25, DIFFICULT_WORD_26, DIFFICULT_WORD_27, DIFFICULT_WORD_28, DIFFICULT_WORD_29, DIFFICULT_WORD_30, DIFFICULT_WORD_31


ALL_WORDS:	.dw EASY_ALL, NORMAL_ALL, DIFFICULT_ALL