import Foundation

struct NavigationalStarEntry: Sendable {
    let name: String
    let bayer: String
    let magnitude: Double
    /// Right Ascension at J2000 in degrees (Hipparcos new reduction, propagated from J1991.25)
    let raJ2000Deg: Double
    /// Declination at J2000 in degrees
    let decJ2000Deg: Double
    /// Proper motion in RA, μα·cos(δ), arcseconds per year
    let pmRAArcsecPerYear: Double
    /// Proper motion in Dec, arcseconds per year
    let pmDecArcsecPerYear: Double
    /// Annual parallax in arcseconds (from Hipparcos new reduction)
    let parallaxArcsec: Double
}

/// The 57 navigational stars (Bowditch / Nautical Almanac) plus Polaris.
/// Astrometry from the Hipparcos new reduction (van Leeuwen 2007, VizieR I/311),
/// propagated from epoch J1991.25 to J2000.0 using the catalog's proper motions.
enum NavigationalStars {
    nonisolated static let all: [NavigationalStarEntry] = [
        .init(name: "Acamar", bayer: "θ Eri", magnitude: 2.88, raJ2000Deg: 44.5653135525, decJ2000Deg: -40.3046812264, pmRAArcsecPerYear: -0.052890, pmDecArcsecPerYear: 0.021980, parallaxArcsec: 0.0202300),
        .init(name: "Achernar", bayer: "α Eri", magnitude: 0.45, raJ2000Deg: 24.4285228227, decJ2000Deg: -57.2367527944, pmRAArcsecPerYear: 0.087000, pmDecArcsecPerYear: -0.038240, parallaxArcsec: 0.0233900),
        .init(name: "Acrux", bayer: "α Cru", magnitude: 0.77, raJ2000Deg: 186.6495634014, decJ2000Deg: -63.0990928581, pmRAArcsecPerYear: -0.035830, pmDecArcsecPerYear: -0.014860, parallaxArcsec: 0.0101300),
        .init(name: "Adhara", bayer: "ε CMa", magnitude: 1.5, raJ2000Deg: 104.6564531515, decJ2000Deg: -28.9720861574, pmRAArcsecPerYear: 0.003240, pmDecArcsecPerYear: 0.001330, parallaxArcsec: 0.0080500),
        .init(name: "Aldebaran", bayer: "α Tau", magnitude: 0.87, raJ2000Deg: 68.9801627904, decJ2000Deg: 16.5093023508, pmRAArcsecPerYear: 0.063450, pmDecArcsecPerYear: -0.188940, parallaxArcsec: 0.0489400),
        .init(name: "Alioth", bayer: "ε UMa", magnitude: 1.76, raJ2000Deg: 193.5072899667, decJ2000Deg: 55.9598229622, pmRAArcsecPerYear: 0.111910, pmDecArcsecPerYear: -0.008240, parallaxArcsec: 0.0395100),
        .init(name: "Alkaid", bayer: "η UMa", magnitude: 1.85, raJ2000Deg: 206.8851573431, decJ2000Deg: 49.3132667304, pmRAArcsecPerYear: -0.121170, pmDecArcsecPerYear: -0.014910, parallaxArcsec: 0.0313800),
        .init(name: "Al Na\'ir", bayer: "α Gru", magnitude: 1.73, raJ2000Deg: 332.0582696946, decJ2000Deg: -46.9609743840, pmRAArcsecPerYear: 0.126690, pmDecArcsecPerYear: -0.147470, parallaxArcsec: 0.0322900),
        .init(name: "Alnilam", bayer: "ε Ori", magnitude: 1.69, raJ2000Deg: 84.0533889408, decJ2000Deg: -1.2019191358, pmRAArcsecPerYear: 0.001440, pmDecArcsecPerYear: -0.000780, parallaxArcsec: 0.0016500),
        .init(name: "Alphard", bayer: "α Hya", magnitude: 1.99, raJ2000Deg: 141.8968445959, decJ2000Deg: -8.6585995318, pmRAArcsecPerYear: -0.015230, pmDecArcsecPerYear: 0.034370, parallaxArcsec: 0.0180900),
        .init(name: "Alphecca", bayer: "α CrB", magnitude: 2.23, raJ2000Deg: 233.6719500161, decJ2000Deg: 26.7146927808, pmRAArcsecPerYear: 0.120270, pmDecArcsecPerYear: -0.089580, parallaxArcsec: 0.0434600),
        .init(name: "Alpheratz", bayer: "α And", magnitude: 2.07, raJ2000Deg: 2.0969161858, decJ2000Deg: 29.0904311200, pmRAArcsecPerYear: 0.137460, pmDecArcsecPerYear: -0.163440, parallaxArcsec: 0.0336200),
        .init(name: "Altair", bayer: "α Aql", magnitude: 0.76, raJ2000Deg: 297.6958272930, decJ2000Deg: 8.8683211987, pmRAArcsecPerYear: 0.536230, pmDecArcsecPerYear: 0.385290, parallaxArcsec: 0.1949500),
        .init(name: "Ankaa", bayer: "α Phe", magnitude: 2.4, raJ2000Deg: 6.5710475049, decJ2000Deg: -42.3059871969, pmRAArcsecPerYear: 0.233050, pmDecArcsecPerYear: -0.356300, parallaxArcsec: 0.0385000),
        .init(name: "Antares", bayer: "α Sco", magnitude: 1.06, raJ2000Deg: 247.3519154198, decJ2000Deg: -26.4320026119, pmRAArcsecPerYear: -0.012110, pmDecArcsecPerYear: -0.023300, parallaxArcsec: 0.0058900),
        .init(name: "Arcturus", bayer: "α Boo", magnitude: -0.05, raJ2000Deg: 213.9153002235, decJ2000Deg: 19.1824092031, pmRAArcsecPerYear: -1.093390, pmDecArcsecPerYear: -2.000060, parallaxArcsec: 0.0888300),
        .init(name: "Atria", bayer: "α TrA", magnitude: 1.91, raJ2000Deg: 252.1662295069, decJ2000Deg: -69.0277118469, pmRAArcsecPerYear: 0.017990, pmDecArcsecPerYear: -0.031580, parallaxArcsec: 0.0083500),
        .init(name: "Avior", bayer: "ε Car", magnitude: 1.86, raJ2000Deg: 125.6284802425, decJ2000Deg: -59.5094841919, pmRAArcsecPerYear: -0.025520, pmDecArcsecPerYear: 0.022060, parallaxArcsec: 0.0053900),
        .init(name: "Bellatrix", bayer: "γ Ori", magnitude: 1.64, raJ2000Deg: 81.2827635565, decJ2000Deg: 6.3497032644, pmRAArcsecPerYear: -0.008110, pmDecArcsecPerYear: -0.012880, parallaxArcsec: 0.0129200),
        .init(name: "Betelgeuse", bayer: "α Ori", magnitude: 0.45, raJ2000Deg: 88.7929389908, decJ2000Deg: 7.4070639953, pmRAArcsecPerYear: 0.027540, pmDecArcsecPerYear: 0.011300, parallaxArcsec: 0.0065500),
        .init(name: "Canopus", bayer: "α Car", magnitude: -0.62, raJ2000Deg: 95.9879578293, decJ2000Deg: -52.6956613839, pmRAArcsecPerYear: 0.019930, pmDecArcsecPerYear: 0.023240, parallaxArcsec: 0.0105500),
        .init(name: "Capella", bayer: "α Aur", magnitude: 0.08, raJ2000Deg: 79.1723279493, decJ2000Deg: 45.9979914701, pmRAArcsecPerYear: 0.075250, pmDecArcsecPerYear: -0.426890, parallaxArcsec: 0.0762000),
        .init(name: "Deneb", bayer: "α Cyg", magnitude: 1.25, raJ2000Deg: 310.3579797531, decJ2000Deg: 45.2803388065, pmRAArcsecPerYear: 0.002010, pmDecArcsecPerYear: 0.001850, parallaxArcsec: 0.0023100),
        .init(name: "Denebola", bayer: "β Leo", magnitude: 2.14, raJ2000Deg: 177.2649097545, decJ2000Deg: 14.5720580682, pmRAArcsecPerYear: -0.497680, pmDecArcsecPerYear: -0.114670, parallaxArcsec: 0.0909100),
        .init(name: "Diphda", bayer: "β Cet", magnitude: 2.04, raJ2000Deg: 10.8973787386, decJ2000Deg: -17.9866063165, pmRAArcsecPerYear: 0.232550, pmDecArcsecPerYear: 0.031990, parallaxArcsec: 0.0338600),
        .init(name: "Dubhe", bayer: "α UMa", magnitude: 1.81, raJ2000Deg: 165.9319646734, decJ2000Deg: 61.7510346897, pmRAArcsecPerYear: -0.134110, pmDecArcsecPerYear: -0.034700, parallaxArcsec: 0.0265400),
        .init(name: "Elnath", bayer: "β Tau", magnitude: 1.65, raJ2000Deg: 81.5729713321, decJ2000Deg: 28.6074517242, pmRAArcsecPerYear: 0.022760, pmDecArcsecPerYear: -0.173580, parallaxArcsec: 0.0243600),
        .init(name: "Eltanin", bayer: "γ Dra", magnitude: 2.24, raJ2000Deg: 269.1515411786, decJ2000Deg: 51.4888956176, pmRAArcsecPerYear: -0.008480, pmDecArcsecPerYear: -0.022790, parallaxArcsec: 0.0211400),
        .init(name: "Enif", bayer: "ε Peg", magnitude: 2.39, raJ2000Deg: 326.0464839145, decJ2000Deg: 9.8750086494, pmRAArcsecPerYear: 0.026920, pmDecArcsecPerYear: 0.000440, parallaxArcsec: 0.0047300),
        .init(name: "Fomalhaut", bayer: "α PsA", magnitude: 1.17, raJ2000Deg: 344.4126927245, decJ2000Deg: -29.6222370396, pmRAArcsecPerYear: 0.328950, pmDecArcsecPerYear: -0.164670, parallaxArcsec: 0.1298100),
        .init(name: "Gacrux", bayer: "γ Cru", magnitude: 1.59, raJ2000Deg: 187.7914983743, decJ2000Deg: -57.1132134617, pmRAArcsecPerYear: 0.028230, pmDecArcsecPerYear: -0.265080, parallaxArcsec: 0.0368300),
        .init(name: "Gienah", bayer: "γ Crv", magnitude: 2.59, raJ2000Deg: 183.9515450376, decJ2000Deg: -17.5419304581, pmRAArcsecPerYear: -0.158610, pmDecArcsecPerYear: 0.021860, parallaxArcsec: 0.0212300),
        .init(name: "Hadar", bayer: "β Cen", magnitude: 0.61, raJ2000Deg: 210.9558556230, decJ2000Deg: -60.3730351617, pmRAArcsecPerYear: -0.033270, pmDecArcsecPerYear: -0.023160, parallaxArcsec: 0.0083200),
        .init(name: "Hamal", bayer: "α Ari", magnitude: 2.0, raJ2000Deg: 31.7933570977, decJ2000Deg: 23.4624175533, pmRAArcsecPerYear: 0.188550, pmDecArcsecPerYear: -0.148080, parallaxArcsec: 0.0495600),
        .init(name: "Kaus Australis", bayer: "ε Sgr", magnitude: 1.85, raJ2000Deg: 276.0429933514, decJ2000Deg: -34.3846164850, pmRAArcsecPerYear: -0.039420, pmDecArcsecPerYear: -0.124200, parallaxArcsec: 0.0227600),
        .init(name: "Kochab", bayer: "β UMi", magnitude: 2.07, raJ2000Deg: 222.6763574985, decJ2000Deg: 74.1555039369, pmRAArcsecPerYear: -0.032610, pmDecArcsecPerYear: 0.011420, parallaxArcsec: 0.0249100),
        .init(name: "Markab", bayer: "α Peg", magnitude: 2.49, raJ2000Deg: 346.1902226914, decJ2000Deg: 15.2052671481, pmRAArcsecPerYear: 0.060400, pmDecArcsecPerYear: -0.041300, parallaxArcsec: 0.0244600),
        .init(name: "Menkar", bayer: "α Cet", magnitude: 2.54, raJ2000Deg: 45.5698878033, decJ2000Deg: 4.0897387718, pmRAArcsecPerYear: -0.010410, pmDecArcsecPerYear: -0.076850, parallaxArcsec: 0.0130900),
        .init(name: "Menkent", bayer: "θ Cen", magnitude: 2.06, raJ2000Deg: 211.6706147068, decJ2000Deg: -36.3699547536, pmRAArcsecPerYear: -0.520530, pmDecArcsecPerYear: -0.518060, parallaxArcsec: 0.0554500),
        .init(name: "Miaplacidus", bayer: "β Car", magnitude: 1.67, raJ2000Deg: 138.2999060708, decJ2000Deg: -69.7172076010, pmRAArcsecPerYear: -0.156470, pmDecArcsecPerYear: 0.108950, parallaxArcsec: 0.0288200),
        .init(name: "Mirfak", bayer: "α Per", magnitude: 1.79, raJ2000Deg: 51.0807087171, decJ2000Deg: 49.8611792965, pmRAArcsecPerYear: 0.023750, pmDecArcsecPerYear: -0.026230, parallaxArcsec: 0.0064400),
        .init(name: "Nunki", bayer: "σ Sgr", magnitude: 2.02, raJ2000Deg: 283.8163604064, decJ2000Deg: -26.2967241146, pmRAArcsecPerYear: 0.015140, pmDecArcsecPerYear: -0.053430, parallaxArcsec: 0.0143200),
        .init(name: "Peacock", bayer: "α Pav", magnitude: 1.94, raJ2000Deg: 306.4119043650, decJ2000Deg: -56.7350897264, pmRAArcsecPerYear: 0.006900, pmDecArcsecPerYear: -0.086020, parallaxArcsec: 0.0182400),
        .init(name: "Pollux", bayer: "β Gem", magnitude: 1.16, raJ2000Deg: 116.3289577678, decJ2000Deg: 28.0261989006, pmRAArcsecPerYear: -0.626550, pmDecArcsecPerYear: -0.045800, parallaxArcsec: 0.0965400),
        .init(name: "Procyon", bayer: "α CMi", magnitude: 0.4, raJ2000Deg: 114.8254979152, decJ2000Deg: 5.2249875800, pmRAArcsecPerYear: -0.714590, pmDecArcsecPerYear: -1.036800, parallaxArcsec: 0.2845600),
        .init(name: "Rasalhague", bayer: "α Oph", magnitude: 2.08, raJ2000Deg: 263.7336227209, decJ2000Deg: 12.5600373918, pmRAArcsecPerYear: 0.108070, pmDecArcsecPerYear: -0.221570, parallaxArcsec: 0.0671300),
        .init(name: "Regulus", bayer: "α Leo", magnitude: 1.36, raJ2000Deg: 152.0929624370, decJ2000Deg: 11.9672087768, pmRAArcsecPerYear: -0.248730, pmDecArcsecPerYear: 0.005590, parallaxArcsec: 0.0411300),
        .init(name: "Rigel", bayer: "β Ori", magnitude: 0.18, raJ2000Deg: 78.6344670669, decJ2000Deg: -8.2016383647, pmRAArcsecPerYear: 0.001310, pmDecArcsecPerYear: 0.000500, parallaxArcsec: 0.0037800),
        .init(name: "Rigil Kent", bayer: "α Cen", magnitude: -0.01, raJ2000Deg: 219.9020576704, decJ2000Deg: -60.8339939387, pmRAArcsecPerYear: -3.679250, pmDecArcsecPerYear: 0.473670, parallaxArcsec: 0.7548100),
        .init(name: "Sabik", bayer: "η Oph", magnitude: 2.43, raJ2000Deg: 257.5945287107, decJ2000Deg: -15.7249066418, pmRAArcsecPerYear: 0.040130, pmDecArcsecPerYear: 0.099170, parallaxArcsec: 0.0369100),
        .init(name: "Schedar", bayer: "α Cas", magnitude: 2.24, raJ2000Deg: 10.1268377807, decJ2000Deg: 56.5373311563, pmRAArcsecPerYear: 0.050880, pmDecArcsecPerYear: -0.032130, parallaxArcsec: 0.0142900),
        .init(name: "Shaula", bayer: "λ Sco", magnitude: 1.62, raJ2000Deg: 263.4021671844, decJ2000Deg: -37.1038235511, pmRAArcsecPerYear: -0.008530, pmDecArcsecPerYear: -0.030800, parallaxArcsec: 0.0057100),
        .init(name: "Sirius", bayer: "α CMa", magnitude: -1.46, raJ2000Deg: 101.2871554081, decJ2000Deg: -16.7161157996, pmRAArcsecPerYear: -0.546010, pmDecArcsecPerYear: -1.223070, parallaxArcsec: 0.3792100),
        .init(name: "Spica", bayer: "α Vir", magnitude: 0.98, raJ2000Deg: 201.2982473616, decJ2000Deg: -11.1613194851, pmRAArcsecPerYear: -0.042350, pmDecArcsecPerYear: -0.030670, parallaxArcsec: 0.0130600),
        .init(name: "Suhail", bayer: "λ Vel", magnitude: 2.21, raJ2000Deg: 136.9989911379, decJ2000Deg: -43.4325909089, pmRAArcsecPerYear: -0.024010, pmDecArcsecPerYear: 0.013520, parallaxArcsec: 0.0059900),
        .init(name: "Vega", bayer: "α Lyr", magnitude: 0.03, raJ2000Deg: 279.2347347809, decJ2000Deg: 38.7836889579, pmRAArcsecPerYear: 0.200940, pmDecArcsecPerYear: 0.286230, parallaxArcsec: 0.1302300),
        .init(name: "Zubenelgenubi", bayer: "α Lib", magnitude: 2.75, raJ2000Deg: 222.7196378918, decJ2000Deg: -16.0417765200, pmRAArcsecPerYear: -0.105680, pmDecArcsecPerYear: -0.068400, parallaxArcsec: 0.0430300),
        .init(name: "Polaris", bayer: "α UMi", magnitude: 2.02, raJ2000Deg: 37.9545609898, decJ2000Deg: 89.2641089779, pmRAArcsecPerYear: 0.044480, pmDecArcsecPerYear: -0.011850, parallaxArcsec: 0.0075400),
    ]

    static let count: Int = all.count
}
