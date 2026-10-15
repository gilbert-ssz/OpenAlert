import '../models/fish_species.dart';
import '../models/water_parameter.dart';

/// Reference water requirements for the species AquaSense can recommend.
///
/// IMPORTANT: These ranges are starting values compiled for the capstone
/// prototype from general aquaculture literature. Before relying on them,
/// have your adviser verify each one against the listed references
/// (BFAR, SEAFDEC Aquaculture Department, FAO Cultured Aquatic Species
/// Information Programme). To change a species or a threshold, edit this
/// file only - the recommendation logic reads everything from here.
/// The Bisaya (Cebuano) texts should also be checked by a native speaker.
const List<FishSpecies> kFishSpecies = [
  // ---------------------------------------------------------------- Fish
  FishSpecies(
    id: 'tilapia',
    group: SpeciesGroup.fish,
    commonName: 'Nile Tilapia',
    localName: 'Tilapia',
    scientificName: 'Oreochromis niloticus',
    imageAsset: 'assets/images/species_tilapia.jpg',
    description:
        'A hardy, fast-growing freshwater fish and one of the most widely '
        'farmed species in the Philippines. Tolerates a wide range of '
        'conditions and can be raised in fresh to low-brackish ponds.',
    descriptionCeb:
        'Lig-on ug paspas modako nga isda sa tab-ang nga tubig. Usa sa '
        'labing daghan nga ginabuhi sa Pilipinas. Makaya niini ang daghang '
        'klase sa kahimtang, ug pwede sa tab-ang hangtod gamay\'g parat nga '
        'tubig.',
    cultureNotes:
        'Grows best in warm fresh water. Some strains are raised in brackish '
        'water after gradual acclimation, but growth is usually best at low '
        'salinity.',
    cultureNotesCeb:
        'Labing maayo modako sa init ug tab-ang nga tubig. Ang ubang klase '
        'pwede sa medyo parat nga tubig kung hinay-hinay nga ipaanad, apan '
        'mas paspas gihapon modako kung gamay ra ang kaparat.',
    requirements: {
      WaterParameter.temperature: SpeciesRequirement(
        optimal: ParameterRange(25, 32),
        tolerable: ParameterRange(20, 35),
      ),
      WaterParameter.ph: SpeciesRequirement(
        optimal: ParameterRange(6.5, 8.5),
        tolerable: ParameterRange(6.0, 9.0),
      ),
      WaterParameter.salinity: SpeciesRequirement(
        optimal: ParameterRange(0, 10),
        tolerable: ParameterRange(0, 15),
      ),
    },
    reference: 'FAO Cultured Aquatic Species Fact Sheet - Oreochromis '
        'niloticus; BFAR tilapia culture guides.',
  ),
  FishSpecies(
    id: 'milkfish',
    group: SpeciesGroup.fish,
    commonName: 'Milkfish',
    localName: 'Bangus',
    scientificName: 'Chanos chanos',
    imageAsset: 'assets/images/species_milkfish.jpg',
    description:
        'The national fish of the Philippines and a staple of brackish-water '
        'fishponds. Milkfish tolerate a very wide salinity range and are '
        'commonly raised in coastal ponds.',
    descriptionCeb:
        'Ang nasudnong isda sa Pilipinas ug kasagaran ginabuhi sa fishpond '
        'nga sagol parat ug tab-ang ang tubig. Makaya sa bangus ang lapad '
        'kaayo nga kaparat, mao nga daghan ang nagbuhi niini sa fishpond '
        'duol sa baybayon.',
    cultureNotes:
        'Traditionally cultured in brackish ponds; also raised in fresh water '
        'and marine pens. Sensitive to low temperatures.',
    cultureNotesCeb:
        'Kasagaran ginabuhi sa fishpond nga sagol parat ug tab-ang; pwede '
        'usab sa tab-ang nga tubig ug sa fish pen sa dagat. Dili kaayo '
        'makaya ang bugnaw nga tubig.',
    requirements: {
      WaterParameter.temperature: SpeciesRequirement(
        optimal: ParameterRange(25, 32),
        tolerable: ParameterRange(20, 35),
      ),
      WaterParameter.ph: SpeciesRequirement(
        optimal: ParameterRange(7.5, 8.5),
        tolerable: ParameterRange(6.5, 9.0),
      ),
      WaterParameter.salinity: SpeciesRequirement(
        optimal: ParameterRange(10, 35),
        tolerable: ParameterRange(0, 50),
      ),
    },
    reference: 'SEAFDEC/AQD milkfish pond culture manuals; FAO Cultured '
        'Aquatic Species Fact Sheet - Chanos chanos.',
  ),
  FishSpecies(
    id: 'seabass',
    group: SpeciesGroup.fish,
    commonName: 'Asian Seabass',
    localName: 'Apahap',
    scientificName: 'Lates calcarifer',
    imageAsset: 'assets/images/species_seabass.jpg',
    description:
        'A high-value carnivorous fish (also called barramundi) that moves '
        'between fresh and salt water in nature. Suited to brackish ponds '
        'with good water quality.',
    descriptionCeb:
        'Mahal nga isda nga mokaon og laing isda (barramundi). Sa kinaiyahan, '
        'mobalhin-balhin kini tali sa tab-ang ug parat nga tubig. Angay sa '
        'fishpond nga sagol parat ug tab-ang ug limpyo ang tubig.',
    cultureNotes:
        'Needs a reliable supply of feed (or forage fish) and well-oxygenated '
        'water. Performs well in brackish conditions.',
    cultureNotesCeb:
        'Kinahanglan og padayon nga suplay sa pagkaon (feeds o gagmayng isda) '
        'ug tubig nga daghan og hangin (oxygen). Maayo modako sa sagol parat '
        'ug tab-ang nga tubig.',
    requirements: {
      WaterParameter.temperature: SpeciesRequirement(
        optimal: ParameterRange(26, 32),
        tolerable: ParameterRange(20, 35),
      ),
      WaterParameter.ph: SpeciesRequirement(
        optimal: ParameterRange(7.5, 8.5),
        tolerable: ParameterRange(7.0, 9.0),
      ),
      WaterParameter.salinity: SpeciesRequirement(
        optimal: ParameterRange(10, 30),
        tolerable: ParameterRange(0, 40),
      ),
    },
    reference: 'SEAFDEC/AQD seabass culture manuals; FAO Cultured Aquatic '
        'Species Fact Sheet - Lates calcarifer.',
  ),
  FishSpecies(
    id: 'catfish',
    group: SpeciesGroup.fish,
    commonName: 'African Catfish',
    localName: 'Hito',
    scientificName: 'Clarias gariepinus',
    imageAsset: 'assets/images/species_catfish.jpg',
    description:
        'A very hardy freshwater catfish that can breathe air, allowing it to '
        'survive in low-oxygen ponds. Popular for small-scale and backyard '
        'culture.',
    descriptionCeb:
        'Lig-on kaayo nga hito sa tab-ang nga tubig. Makaginhawa kini og '
        'hangin, mao nga mabuhi bisan kulang ang oxygen sa tubig. Sikat sa '
        'gagmay ug backyard nga pagbuhi.',
    cultureNotes:
        'A freshwater species with limited salt tolerance. Tolerates poor '
        'water quality better than most fish, but grows best in clean water.',
    cultureNotesCeb:
        'Isda sa tab-ang nga tubig; gamay ra ang maagwanta nga kaparat. '
        'Makaya ang dili kaayo limpyo nga tubig, apan mas maayo modako sa '
        'limpyo nga tubig.',
    requirements: {
      WaterParameter.temperature: SpeciesRequirement(
        optimal: ParameterRange(25, 30),
        tolerable: ParameterRange(20, 33),
      ),
      WaterParameter.ph: SpeciesRequirement(
        optimal: ParameterRange(6.5, 8.0),
        tolerable: ParameterRange(6.0, 9.0),
      ),
      WaterParameter.salinity: SpeciesRequirement(
        optimal: ParameterRange(0, 3),
        tolerable: ParameterRange(0, 8),
      ),
    },
    reference: 'FAO Cultured Aquatic Species Fact Sheet - Clarias '
        'gariepinus; BFAR catfish culture guides.',
  ),
  FishSpecies(
    id: 'carp',
    group: SpeciesGroup.fish,
    commonName: 'Common Carp',
    localName: 'Karpa',
    scientificName: 'Cyprinus carpio',
    imageAsset: 'assets/images/species_carp.jpg',
    description:
        'A freshwater fish farmed worldwide, often in polyculture with '
        'tilapia. It feeds near the pond bottom and adapts to a range of '
        'temperatures.',
    descriptionCeb:
        'Isda sa tab-ang nga tubig nga ginabuhi sa tibuok kalibutan, '
        'kasagaran kauban sa tilapia. Mokaon kini duol sa salog sa fishpond '
        'ug makaya ang lain-laing kainit sa tubig.',
    cultureNotes:
        'Strictly a freshwater species with low salt tolerance. Prefers '
        'slightly cooler water than most tropical species.',
    cultureNotesCeb:
        'Para lang sa tab-ang nga tubig; gamay ra kaayo ang maagwanta nga '
        'kaparat. Mas gusto niini ang medyo bugnaw nga tubig kaysa ubang isda '
        'dinhi sa atong lugar.',
    requirements: {
      WaterParameter.temperature: SpeciesRequirement(
        optimal: ParameterRange(23, 30),
        tolerable: ParameterRange(15, 33),
      ),
      WaterParameter.ph: SpeciesRequirement(
        optimal: ParameterRange(6.5, 8.5),
        tolerable: ParameterRange(6.0, 9.0),
      ),
      WaterParameter.salinity: SpeciesRequirement(
        optimal: ParameterRange(0, 3),
        tolerable: ParameterRange(0, 6),
      ),
    },
    reference: 'FAO Cultured Aquatic Species Fact Sheet - Cyprinus carpio.',
  ),

  // ------------------------------------------------------- Shrimp & prawn
  FishSpecies(
    id: 'tiger_prawn',
    group: SpeciesGroup.shrimp,
    commonName: 'Giant Tiger Prawn',
    localName: 'Sugpo',
    scientificName: 'Penaeus monodon',
    imageAsset: 'assets/images/species_tiger_prawn.jpg',
    description:
        'A large, high-value prawn (also called lukon) and a major export '
        'product of the Philippines. Raised in brackish ponds near the coast; '
        'it grows big but needs careful water management.',
    descriptionCeb:
        'Dako ug mahal nga pasayan (lukon) nga gi-export sa Pilipinas. '
        'Ginabuhi sa fishpond duol sa baybayon nga sagol parat ug tab-ang ang '
        'tubig. Modako kini og maayo apan kinahanglan bantayan pag-ayo ang '
        'tubig.',
    cultureNotes:
        'Grows best in brackish water with stable salinity and good aeration. '
        'Sudden changes in salinity, temperature or pH stress the prawns, and '
        'disease spreads easily when water quality is poor.',
    cultureNotesCeb:
        'Labing maayo sa sagol parat ug tab-ang nga tubig nga dili kaayo '
        'mausab ang kaparat, ug daghan og hangin (aerator). Ma-stress kini '
        'kung kalit mausab ang kaparat, kainit o pH, ug dali masakit kung '
        'hugaw ang tubig.',
    requirements: {
      WaterParameter.temperature: SpeciesRequirement(
        optimal: ParameterRange(27, 32),
        tolerable: ParameterRange(22, 35),
      ),
      WaterParameter.ph: SpeciesRequirement(
        optimal: ParameterRange(7.5, 8.5),
        tolerable: ParameterRange(7.0, 9.0),
      ),
      WaterParameter.salinity: SpeciesRequirement(
        optimal: ParameterRange(15, 25),
        tolerable: ParameterRange(5, 35),
      ),
    },
    reference: 'SEAFDEC/AQD tiger shrimp (Penaeus monodon) culture manuals; '
        'FAO Cultured Aquatic Species Fact Sheet - Penaeus monodon; BFAR '
        'shrimp culture guides.',
  ),
  FishSpecies(
    id: 'vannamei',
    group: SpeciesGroup.shrimp,
    commonName: 'Whiteleg Shrimp',
    localName: 'Vannamei',
    scientificName: 'Litopenaeus vannamei',
    imageAsset: 'assets/images/species_vannamei.jpg',
    description:
        'A fast-growing shrimp now widely farmed in the Philippines. It '
        'tolerates a wide salinity range, so it can be raised in brackish '
        'ponds and, after gradual acclimation, in low-salinity water.',
    descriptionCeb:
        'Paspas modako nga pasayan nga daghan na karon ang nagbuhi sa '
        'Pilipinas. Makaya niini ang lapad nga kaparat, mao nga pwede sa '
        'sagol parat ug tab-ang, ug bisan sa gamay\'g parat nga tubig kung '
        'hinay-hinay nga ipaanad.',
    cultureNotes:
        'Can be stocked more densely than tiger prawn but needs aeration and '
        'good feed. For low-salinity ponds, acclimate the post-larvae '
        'gradually. Check BFAR rules and permits before stocking.',
    cultureNotesCeb:
        'Pwede mas daghan ang ibutang kaysa sugpo apan kinahanglan og aerator '
        'ug maayong feeds. Kung gamay\'g parat ang tubig, hinay-hinay '
        'ipaanad ang semilya (post-larvae). Pangutana sa BFAR bahin sa mga '
        'lagda ug permit una mag-stock.',
    requirements: {
      WaterParameter.temperature: SpeciesRequirement(
        optimal: ParameterRange(26, 32),
        tolerable: ParameterRange(20, 35),
      ),
      WaterParameter.ph: SpeciesRequirement(
        optimal: ParameterRange(7.5, 8.5),
        tolerable: ParameterRange(7.0, 9.0),
      ),
      WaterParameter.salinity: SpeciesRequirement(
        optimal: ParameterRange(10, 25),
        tolerable: ParameterRange(2, 40),
      ),
    },
    reference: 'FAO Cultured Aquatic Species Fact Sheet - Penaeus vannamei; '
        'BFAR guidelines on whiteleg shrimp culture.',
  ),

  // ---------------------------------------------------------------- Crab
  FishSpecies(
    id: 'mud_crab',
    group: SpeciesGroup.crab,
    commonName: 'Mud Crab',
    localName: 'Alimango',
    scientificName: 'Scylla serrata',
    imageAsset: 'assets/images/species_mud_crab.jpg',
    description:
        'A large, high-value crab of mangrove areas. In the Philippines it is '
        'often raised in brackish ponds - alone or together with milkfish - '
        'and sold live.',
    descriptionCeb:
        'Dako ug mahal nga alimango nga makita sa katunggan (bakhawan). Sa '
        'Pilipinas, kasagaran ginabuhi sa fishpond nga sagol parat ug tab-ang '
        '- usahay kauban sa bangus - ug ginabaligya nga buhi.',
    cultureNotes:
        'Needs a secure fence or net around the pond because crabs climb and '
        'burrow. Provide hiding places to reduce fighting. Feeds on trash '
        'fish and mussels.',
    cultureNotesCeb:
        'Kinahanglan og lig-on nga koral o pukot palibot sa fishpond kay '
        'mosaka ug mokalot ang alimango. Butangi og tagoanan aron dili '
        'mag-away. Pakan-a og gagmayng isda o tahong.',
    requirements: {
      WaterParameter.temperature: SpeciesRequirement(
        optimal: ParameterRange(26, 30),
        tolerable: ParameterRange(20, 35),
      ),
      WaterParameter.ph: SpeciesRequirement(
        optimal: ParameterRange(7.5, 8.5),
        tolerable: ParameterRange(7.0, 9.0),
      ),
      WaterParameter.salinity: SpeciesRequirement(
        optimal: ParameterRange(15, 30),
        tolerable: ParameterRange(5, 40),
      ),
    },
    reference: 'SEAFDEC/AQD mud crab (Scylla) grow-out manuals; FAO Cultured '
        'Aquatic Species Fact Sheet - Scylla serrata.',
  ),
];
