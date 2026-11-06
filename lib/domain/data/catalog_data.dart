import 'package:quick_kart/domain/models/catalog.dart';
import 'package:flutter/material.dart';

const List<Category> appCategories = [
  Category(id: 'dairy', title: 'Dairy', emoji: '🥛', color: Color(0xFFE8F1FF)),
  Category(
    id: 'fruits',
    title: 'Fruits',
    emoji: '🍎',
    color: Color(0xFFFFE9E7),
  ),
  Category(
    id: 'vegetables',
    title: 'Vegetables',
    emoji: '🥦',
    color: Color(0xFFE7F5E9),
  ),
  Category(
    id: 'bakery',
    title: 'Bakery',
    emoji: '🍞',
    color: Color(0xFFFFF2DB),
  ),
  Category(
    id: 'snacks',
    title: 'Snacks',
    emoji: '🍫',
    color: Color(0xFFF3E8DF),
  ),
  Category(
    id: 'drinks',
    title: 'Drinks',
    emoji: '🧃',
    color: Color(0xFFFFEDD9),
  ),
  Category(id: 'care', title: 'Care', emoji: '🧴', color: Color(0xFFEDE9FF)),
  Category(id: 'home', title: 'Home', emoji: '🧹', color: Color(0xFFE6F4F1)),
  Category(
    id: 'staples',
    title: 'Atta, Rice & Dal',
    emoji: '🌾',
    color: Color(0xFFFFF3E0),
  ),
  Category(
    id: 'spices',
    title: 'Spices & Sauces',
    emoji: '🧂',
    color: Color(0xFFFDECE5),
  ),
  Category(
    id: 'meat',
    title: 'Meat & Fish',
    emoji: '🥩',
    color: Color(0xFFFDE8E8),
  ),
  Category(
    id: 'frozen',
    title: 'Instant & Frozen',
    emoji: '🥟',
    color: Color(0xFFEAF1F8),
  ),
  Category(
    id: 'tea',
    title: 'Tea & Coffee',
    emoji: '🍵',
    color: Color(0xFFF6EEDD),
  ),
  Category(
    id: 'baby',
    title: 'Baby Care',
    emoji: '🍼',
    color: Color(0xFFFFEAF2),
  ),
  Category(
    id: 'pets',
    title: 'Pet Care',
    emoji: '🐾',
    color: Color(0xFFEAF3E6),
  ),
  Category(
    id: 'pharma',
    title: 'Pharmacy',
    emoji: '💊',
    color: Color(0xFFE9F0FE),
  ),
];

const List<Product> appProducts = [
  Product(
    id: 'amul-milk',
    name: 'Amul Taaza Milk',
    unit: '500 ml',
    emoji: '🥛',
    price: 290,
    tint: Color(0xFFE8F1FF),
    categoryId: 'dairy',
    description:
        'Amul Taaza is fresh toned dairy, chilled from the store and ready '
        'to pour over cereal or into tea.',
  ),
  Product(
    id: 'farm-eggs',
    name: 'Farm Eggs',
    unit: '6 pcs',
    emoji: '🥚',
    price: 220,
    tint: Color(0xFFFDF0DE),
    categoryId: 'dairy',
    description:
        'Half a dozen farm fresh eggs with rich golden yolks, perfect for '
        'a protein packed breakfast.',
  ),
  Product(
    id: 'nestle-yogurt',
    name: 'Nestlé Yogurt',
    unit: '400 g',
    emoji: '🥣',
    price: 180,
    tint: Color(0xFFEAF3FF),
    categoryId: 'dairy',
    description:
        'Creamy set yogurt made from fresh dairy, great alongside meals '
        'or as a cool dessert.',
  ),
  Product(
    id: 'bananas',
    name: 'Fresh Bananas',
    unit: '6 pcs',
    emoji: '🍌',
    price: 180,
    tint: Color(0xFFFFF6D6),
    categoryId: 'fruits',
    description:
        'Naturally sweet fruit rich in potassium, perfect for snacking, '
        'shakes and lunchboxes.',
  ),
  Product(
    id: 'apples',
    name: 'Kashmiri Apples',
    unit: '4 pcs',
    emoji: '🍎',
    price: 350,
    tint: Color(0xFFFDE4E1),
    categoryId: 'fruits',
    description:
        'Crisp Kashmiri apples with a sweet tart flavour, hand picked at '
        'peak ripeness.',
  ),
  Product(
    id: 'mangoes',
    name: 'Sindhri Mangoes',
    unit: '1 kg',
    emoji: '🥭',
    price: 450,
    tint: Color(0xFFFFF1D6),
    categoryId: 'fruits',
    description:
        'Juicy Sindhri mangoes with a rich summer aroma, the crown of '
        'Pakistani fruit season.',
  ),
  Product(
    id: 'broccoli',
    name: 'Broccoli',
    unit: '250 g',
    emoji: '🥦',
    price: 190,
    tint: Color(0xFFE6F4E7),
    categoryId: 'vegetables',
    description:
        'Fresh green florets full of fibre, ideal for salads, soups and '
        'quick stir fries.',
  ),
  Product(
    id: 'tomatoes',
    name: 'Tomatoes',
    unit: '500 g',
    emoji: '🍅',
    price: 120,
    tint: Color(0xFFFDE7E3),
    categoryId: 'vegetables',
    description:
        'Ripe red tomatoes with firm skin, ready for salads, gravies and '
        'chutney.',
  ),
  Product(
    id: 'potatoes',
    name: 'Potatoes',
    unit: '1 kg',
    emoji: '🥔',
    price: 150,
    tint: Color(0xFFF3EBDD),
    categoryId: 'vegetables',
    description:
        'Everyday all rounder vegetable for fries, curries, biryani and '
        'anything in between.',
  ),
  Product(
    id: 'wheat-bread',
    name: 'Whole Wheat Bread',
    unit: '400 g',
    emoji: '🍞',
    price: 240,
    tint: Color(0xFFF5E7D3),
    categoryId: 'bakery',
    description:
        'Soft whole grain loaf baked fresh each morning, full of fibre '
        'for healthier sandwiches.',
  ),
  Product(
    id: 'croissants',
    name: 'Butter Croissants',
    unit: '2 pcs',
    emoji: '🥐',
    price: 160,
    tint: Color(0xFFFFF0DB),
    categoryId: 'bakery',
    description:
        'Flaky buttery layers baked golden, perfect with tea or coffee '
        'on a slow morning.',
  ),
  Product(
    id: 'muffin',
    name: 'Chocolate Muffin',
    unit: '1 pc',
    emoji: '🧁',
    price: 130,
    tint: Color(0xFFF3E6EA),
    categoryId: 'bakery',
    description:
        'Soft chocolate treat with rich cocoa flavour packed into every '
        'single bite.',
  ),
  Product(
    id: 'dairy-milk',
    name: 'Dairy Milk Chocolate',
    unit: '50 g',
    emoji: '🍫',
    price: 150,
    tint: Color(0xFFF3E6DC),
    categoryId: 'snacks',
    description:
        'Classic cream chocolate bar, smooth and silky with a melt in '
        'the mouth finish.',
  ),
  Product(
    id: 'salted-chips',
    name: 'Salted Chips',
    unit: '90 g',
    emoji: '🍟',
    price: 120,
    tint: Color(0xFFFFF3D6),
    categoryId: 'snacks',
    description:
        'Crispy golden chips with just the right pinch of salt, sealed '
        'stays crunchy.',
  ),
  Product(
    id: 'orange-juice',
    name: 'Orange Juice',
    unit: '1 L',
    emoji: '🧃',
    price: 420,
    tint: Color(0xFFFFE9D6),
    categoryId: 'drinks',
    description:
        'Chilled juice squeezed from ripe oranges, sunny citrus flavour '
        'with no added sugar.',
  ),
  Product(
    id: 'cola',
    name: 'Cola',
    unit: '1.5 L',
    emoji: '🥤',
    price: 180,
    tint: Color(0xFFF1E4E4),
    categoryId: 'drinks',
    description:
        'Ice cold fizzy cola with a bold taste, made for sharing at '
        'dinner or dawats.',
  ),
  Product(
    id: 'hand-wash',
    name: 'Hand Wash',
    unit: '250 ml',
    emoji: '🧴',
    price: 280,
    tint: Color(0xFFEDE9FF),
    categoryId: 'care',
    description:
        'Gentle antibacterial liquid soap with a fresh fragrance, kind '
        'to busy hands.',
  ),
  Product(
    id: 'toothpaste',
    name: 'Toothpaste',
    unit: '100 g',
    emoji: '🪥',
    price: 240,
    tint: Color(0xFFE4F2F7),
    categoryId: 'care',
    description:
        'Fluoride toothpaste for strong enamel and long lasting fresh '
        'morning breath.',
  ),
  Product(
    id: 'dish-wash',
    name: 'Dish Wash Liquid',
    unit: '500 ml',
    emoji: '🧽',
    price: 320,
    tint: Color(0xFFE6F4F1),
    categoryId: 'home',
    description:
        'Powerful grease cutting formula that leaves dishes sparkling '
        'clean with little effort.',
  ),
  Product(
    id: 'floor-cleaner',
    name: 'Floor Cleaner',
    unit: '1 L',
    emoji: '🧹',
    price: 360,
    tint: Color(0xFFEAF2E3),
    categoryId: 'home',
    description:
        'Disinfectant cleaner that removes stains and leaves floors '
        'fresh with a pleasant scent.',
  ),

  // Vegetables — superstore additions.
  Product(
    id: 'onions',
    name: 'Onions',
    unit: '1 kg',
    emoji: '🧅',
    price: 140,
    tint: Color(0xFFF0E4DE),
    categoryId: 'vegetables',
    description:
        'Firm red onions with a sharp flavour, the base of every true '
        'Pakistani dish.',
  ),
  Product(
    id: 'garlic',
    name: 'Garlic',
    unit: '250 g',
    emoji: '🧄',
    price: 120,
    tint: Color(0xFFF3EDDC),
    categoryId: 'vegetables',
    description:
        'Fresh plump garlic bulbs, aromatic and easy to peel for daily '
        'cooking.',
  ),
  Product(
    id: 'fresh-lemons',
    name: 'Fresh Lemons',
    unit: '4 pcs',
    emoji: '🍋',
    price: 80,
    tint: Color(0xFFFFF4CF),
    categoryId: 'vegetables',
    description:
        'Bright juicy lemons loaded with vitamin C, ready for lemonade, '
        'salads and dahi baray.',
  ),
  Product(
    id: 'cucumber',
    name: 'Cucumber',
    unit: '500 g',
    emoji: '🥒',
    price: 110,
    tint: Color(0xFFE7F3E7),
    categoryId: 'vegetables',
    description:
        'Cool crunchy cucumbers with thin skin, ideal for salads, raita '
        'and snacking.',
  ),
  Product(
    id: 'carrots',
    name: 'Carrots',
    unit: '1 kg',
    emoji: '🥕',
    price: 130,
    tint: Color(0xFFFDEBDC),
    categoryId: 'vegetables',
    description:
        'Sweet crunchy carrots rich in vitamin A, great raw, steamed or '
        'in gajar halwa.',
  ),
  Product(
    id: 'salad-greens',
    name: 'Salad Greens',
    unit: '250 g',
    emoji: '🥬',
    price: 160,
    tint: Color(0xFFE6F4E7),
    categoryId: 'vegetables',
    description:
        'Crisp leafy greens, triple washed and ready to toss straight '
        'into the bowl.',
  ),

  // Fruits — superstore additions.
  Product(
    id: 'grapes',
    name: 'Fresh Grapes',
    unit: '500 g',
    emoji: '🍇',
    price: 320,
    tint: Color(0xFFECE4F6),
    categoryId: 'fruits',
    description:
        'Seedless grapes so sweet and juicy they disappear straight from '
        'the box.',
  ),
  Product(
    id: 'watermelon',
    name: 'Watermelon',
    unit: '1 pc',
    emoji: '🍉',
    price: 250,
    tint: Color(0xFFFDE1E1),
    categoryId: 'fruits',
    description:
        'Big juicy melon with sweet red flesh and a thin green rind, the '
        'summer cooler of choice.',
  ),
  Product(
    id: 'oranges',
    name: 'Kinnow Oranges',
    unit: '1 kg',
    emoji: '🍊',
    price: 260,
    tint: Color(0xFFFFEDD8),
    categoryId: 'fruits',
    description:
        'Sweet kinnow oranges, easy to peel and bursting with fresh '
        'citrus juice.',
  ),

  // Dairy — superstore additions.
  Product(
    id: 'cheese-slices',
    name: 'Cheese Slices',
    unit: '10 pcs',
    emoji: '🧀',
    price: 460,
    tint: Color(0xFFFFF2D9),
    categoryId: 'dairy',
    description:
        'Smooth cheese slices that melt perfectly over burgers and '
        'sandwiches.',
  ),
  Product(
    id: 'butter',
    name: 'Butter',
    unit: '200 g',
    emoji: '🧈',
    price: 390,
    tint: Color(0xFFFDF5DE),
    categoryId: 'dairy',
    description:
        'Creamy salted butter churned fresh, for toast, parathas and '
        'baking day.',
  ),

  // Bakery — superstore additions.
  Product(
    id: 'sesame-buns',
    name: 'Sesame Buns',
    unit: '4 pcs',
    emoji: '🥯',
    price: 150,
    tint: Color(0xFFFFF0DB),
    categoryId: 'bakery',
    description:
        'Soft sesame topped buns, ideal for homemade burgers and bun '
        'kebabs.',
  ),
  Product(
    id: 'donut',
    name: 'Chocolate Donut',
    unit: '4 pcs',
    emoji: '🍩',
    price: 280,
    tint: Color(0xFFF7E5DC),
    categoryId: 'bakery',
    description:
        'Fluffy ring with a chocolate glaze, soft inside and sweet on '
        'top.',
  ),
  Product(
    id: 'cream-cake',
    name: 'Fresh Cream Cake',
    unit: '500 g',
    emoji: '🍰',
    price: 950,
    tint: Color(0xFFF9E7EF),
    categoryId: 'bakery',
    description:
        'Light sponge layered with fresh cream and fruits, perfect '
        'centre piece for celebrations.',
  ),

  // Snacks — superstore additions.
  Product(
    id: 'tea-biscuits',
    name: 'Tea Time Biscuits',
    unit: 'family pack',
    emoji: '🍪',
    price: 90,
    tint: Color(0xFFEFE0CE),
    categoryId: 'snacks',
    description:
        'Crisp classic biscuits that pair perfectly with evening tea '
        'and family gossip.',
  ),
  Product(
    id: 'corn-puffs',
    name: 'Corn Puffs',
    unit: '70 g',
    emoji: '🌽',
    price: 50,
    tint: Color(0xFFFFF3D6),
    categoryId: 'snacks',
    description:
        'Light crunchy puffed corn snack, dangerously easy to finish in '
        'one sitting.',
  ),
  Product(
    id: 'peanuts',
    name: 'Roasted Peanuts',
    unit: '200 g',
    emoji: '🥜',
    price: 160,
    tint: Color(0xFFF5E8D8),
    categoryId: 'snacks',
    description:
        'Slow roasted peanuts with a salt dusting, a protein rich snack '
        'for busy days.',
  ),
  Product(
    id: 'popcorn',
    name: 'Butter Popcorn',
    unit: '180 g',
    emoji: '🍿',
    price: 250,
    tint: Color(0xFFFFF1DA),
    categoryId: 'snacks',
    description:
        'Movie night popcorn with real butter flavour, ready in '
        'minutes in the microwave.',
  ),

  // Drinks — superstore additions.
  Product(
    id: 'mineral-water',
    name: 'Mineral Water',
    unit: '1.5 L',
    emoji: '💧',
    price: 70,
    tint: Color(0xFFE7F1FA),
    categoryId: 'drinks',
    description:
        'Sealed bottled water from a trusted source, clean and '
        'refreshing for any time of day.',
  ),
  Product(
    id: 'mango-juice',
    name: 'Mango Juice',
    unit: '1 L',
    emoji: '🧃',
    price: 380,
    tint: Color(0xFFFFE9D6),
    categoryId: 'drinks',
    description:
        'Thick pulpy mango drink made from ripe Sindhri mangoes, summer '
        'in every glass.',
  ),
  Product(
    id: 'lemon-soda',
    name: 'Lemon Soda',
    unit: '345 ml',
    emoji: '🥤',
    price: 90,
    tint: Color(0xFFEFF7E3),
    categoryId: 'drinks',
    description:
        'Zesty sparkling lemon soda, a chilled burst of refreshment on '
        'hot afternoons.',
  ),

  // Tea & Coffee.
  Product(
    id: 'danedar-tea',
    name: 'Tapal Danedar Tea',
    unit: '900 g',
    emoji: '🍵',
    price: 1650,
    tint: Color(0xFFEFE7D3),
    categoryId: 'tea',
    description:
        'Strong granulated black tea blend for a perfectly bold, aromatic, '
        'refreshing strong cup of tea every time.',
  ),
  Product(
    id: 'nescafe',
    name: 'Nescafé Classic',
    unit: '200 g',
    emoji: '☕',
    price: 1290,
    tint: Color(0xFFEFE6DF),
    categoryId: 'tea',
    description:
        'Instant coffee with a rich aroma, hot and ready within '
        'seconds any time of day.',
  ),
  Product(
    id: 'green-tea',
    name: 'Green Tea Bags',
    unit: '25 pcs',
    emoji: '🍵',
    price: 240,
    tint: Color(0xFFE7F0E3),
    categoryId: 'tea',
    description:
        'Light green tea with calming herbs for a healthy and relaxing '
        'evening.',
  ),

  // Atta, Rice & Dal.
  Product(
    id: 'chakki-atta',
    name: 'Chakki Fresh Atta',
    unit: '10 kg',
    emoji: '🌾',
    price: 1890,
    tint: Color(0xFFFFF1DC),
    categoryId: 'staples',
    description:
        'Stone ground whole grain flour for soft everyday rotis the '
        'whole family loves.',
  ),
  Product(
    id: 'basmati-rice',
    name: 'Basmati Rice',
    unit: '5 kg',
    emoji: '🍚',
    price: 2450,
    tint: Color(0xFFF9F2E6),
    categoryId: 'staples',
    description:
        'Aged long grain basmati that fluffs up into the perfect '
        'biryani or pulao.',
  ),
  Product(
    id: 'white-sugar',
    name: 'White Sugar',
    unit: '5 kg',
    emoji: '🫙',
    price: 850,
    tint: Color(0xFFF7F3EE),
    categoryId: 'staples',
    description:
        'Refined white sugar with fine crystals, for chai, baking and '
        'desserts.',
  ),
  Product(
    id: 'cooking-oil',
    name: 'Cooking Oil',
    unit: '5 L',
    emoji: '🛢',
    price: 3350,
    tint: Color(0xFFFFEFD9),
    categoryId: 'staples',
    description:
        'Refined kitchen oil that is light on the stomach and neutral '
        'in taste for all cooking.',
  ),
  Product(
    id: 'chana-dal',
    name: 'Chana Dal',
    unit: '1 kg',
    emoji: '🫘',
    price: 320,
    tint: Color(0xFFF6ECD9),
    categoryId: 'staples',
    description:
        'Clean protein rich split lentil, quick to cook and easy on '
        'the tummy.',
  ),
  Product(
    id: 'iodised-salt',
    name: 'Iodised Salt',
    unit: '800 g',
    emoji: '🧂',
    price: 60,
    tint: Color(0xFFEFF3F6),
    categoryId: 'staples',
    description:
        'Free flowing iodised salt that keeps everyday meals healthy '
        'and well seasoned.',
  ),

  // Spices & Sauces.
  Product(
    id: 'biryani-masala',
    name: 'Biryani Masala',
    unit: '50 g',
    emoji: '🫙',
    price: 120,
    tint: Color(0xFFF9E4D8),
    categoryId: 'spices',
    description:
        'Signature spice mix with saffron hints for restaurant style '
        'biryani at home.',
  ),
  Product(
    id: 'red-chilli-powder',
    name: 'Red Chilli Powder',
    unit: '200 g',
    emoji: '🫙',
    price: 250,
    tint: Color(0xFFFBE3DB),
    categoryId: 'spices',
    description:
        'Vivid sun dried chilli powder that adds heat and colour to '
        'every curry.',
  ),
  Product(
    id: 'tomato-ketchup',
    name: 'Tomato Ketchup',
    unit: '800 g',
    emoji: '🍅',
    price: 340,
    tint: Color(0xFFFDE3DC),
    categoryId: 'spices',
    description:
        'Thick tangy sauce made from ripe tomatoes, a favourite of '
        'kids and fries alike.',
  ),
  Product(
    id: 'soy-sauce',
    name: 'Soy Sauce',
    unit: '200 ml',
    emoji: '🍶',
    price: 280,
    tint: Color(0xFFEDE9E9),
    categoryId: 'spices',
    description:
        'Naturally brewed dark sauce for stir fries, noodles and '
        'marinades.',
  ),

  // Meat & Fish.
  Product(
    id: 'fresh-chicken',
    name: 'Fresh Chicken',
    unit: '1 kg',
    emoji: '🍗',
    price: 780,
    tint: Color(0xFFFDECE2),
    categoryId: 'meat',
    description:
        'Farm raised broiler chicken, cleaned, halal certified and '
        'ready for the pot.',
  ),
  Product(
    id: 'beef-mince',
    name: 'Beef Mince',
    unit: '1 kg',
    emoji: '🥩',
    price: 1450,
    tint: Color(0xFFF9E4E4),
    categoryId: 'meat',
    description:
        'Fresh lean mince ground daily, ideal for kebabs, qeema and '
        'spaghetti.',
  ),
  Product(
    id: 'fresh-fish',
    name: 'Fresh Fish',
    unit: '1 kg',
    emoji: '🐟',
    price: 1100,
    tint: Color(0xFFE7F1F2),
    categoryId: 'meat',
    description:
        'Local river fish, scaled and cleaned, ready for the fryer or '
        'the grill.',
  ),

  // Instant & Frozen.
  Product(
    id: 'maggi-noodles',
    name: 'Maggi Noodles',
    unit: '4 pack',
    emoji: '🍜',
    price: 340,
    tint: Color(0xFFFDEAD9),
    categoryId: 'frozen',
    description:
        'Instant masala noodles, the two minute fix for late night '
        'hunger.',
  ),
  Product(
    id: 'frozen-fries',
    name: 'Frozen French Fries',
    unit: '750 g',
    emoji: '🍟',
    price: 350,
    tint: Color(0xFFFFF0D6),
    categoryId: 'frozen',
    description:
        'Golden fries straight from the freezer, fry or air fry into '
        'crispy perfection.',
  ),
  Product(
    id: 'chicken-nuggets',
    name: 'Chicken Nuggets',
    unit: '400 g',
    emoji: '🍗',
    price: 560,
    tint: Color(0xFFFBEEDF),
    categoryId: 'frozen',
    description:
        'Crunchy golden coated nuggets filled with juicy chicken '
        'inside.',
  ),
  Product(
    id: 'vanilla-ice-cream',
    name: 'Vanilla Ice Cream',
    unit: '1 L',
    emoji: '🍨',
    price: 640,
    tint: Color(0xFFFBEFF5),
    categoryId: 'frozen',
    description:
        'Rich creamy classic tub, hand churned taste for sundaes and '
        'indulgent nights.',
  ),
  Product(
    id: 'frozen-samosa',
    name: 'Frozen Samosa',
    unit: '12 pcs',
    emoji: '🥟',
    price: 320,
    tint: Color(0xFFFAF0E3),
    categoryId: 'frozen',
    description:
        'Ready to fry samosas with spiced potato filling, guests at '
        'the door in minutes.',
  ),

  // Care — superstore additions.
  Product(
    id: 'shampoo',
    name: 'Anti-Dandruff Shampoo',
    unit: '200 ml',
    emoji: '🚿',
    price: 620,
    tint: Color(0xFFE5F0F6),
    categoryId: 'care',
    description:
        'Anti dandruff formula that soothes the scalp and leaves hair '
        'soft and shiny.',
  ),
  Product(
    id: 'beauty-soap',
    name: 'Beauty Soap',
    unit: '3 pcs',
    emoji: '🧼',
    price: 240,
    tint: Color(0xFFEFE9E4),
    categoryId: 'care',
    description:
        'Mild moisturising soap bars with a soft floral scent for the '
        'whole family.',
  ),
  Product(
    id: 'face-wash',
    name: 'Face Wash',
    unit: '150 ml',
    emoji: '🧴',
    price: 480,
    tint: Color(0xFFFDE9F1),
    categoryId: 'care',
    description:
        'Gentle daily face wash that cleans pores without drying out '
        'the skin.',
  ),

  // Home — superstore additions.
  Product(
    id: 'detergent',
    name: 'Detergent Powder',
    unit: '1 kg',
    emoji: '🧺',
    price: 780,
    tint: Color(0xFFE8EFE3),
    categoryId: 'home',
    description:
        'High foam laundry powder that lifts tough stains fast, even '
        'in cold water.',
  ),
  Product(
    id: 'toilet-tissue',
    name: 'Toilet Tissue',
    unit: '8 rolls',
    emoji: '🧻',
    price: 620,
    tint: Color(0xFFF5EFEA),
    categoryId: 'home',
    description:
        'Soft absorbent tissue rolls, gentle on skin and strong where '
        'it counts.',
  ),
  Product(
    id: 'plastic-bucket',
    name: 'Plastic Bucket',
    unit: '1 pc',
    emoji: '🪣',
    price: 290,
    tint: Color(0xFFE4EFF5),
    categoryId: 'home',
    description:
        'Sturdy household bucket with a strong handle for laundry and '
        'daily chores.',
  ),

  // Baby Care.
  Product(
    id: 'baby-diapers',
    name: 'Baby Diapers',
    unit: '54 pcs',
    emoji: '👶',
    price: 3400,
    tint: Color(0xFFFFEFE3),
    categoryId: 'baby',
    description:
        'Ultra dry baby diapers with soft leak protection for day '
        'nights and naps.',
  ),
  Product(
    id: 'baby-shampoo',
    name: 'Baby Shampoo',
    unit: '200 ml',
    emoji: '🛁',
    price: 520,
    tint: Color(0xFFFDEFF5),
    categoryId: 'baby',
    description:
        'No tears formula that keeps your little one hair soft, clean '
        'and tangle free.',
  ),
  Product(
    id: 'baby-lotion',
    name: 'Baby Lotion',
    unit: '200 ml',
    emoji: '🧴',
    price: 560,
    tint: Color(0xFFFFEFE6),
    categoryId: 'baby',
    description:
        'Mild hypoallergenic lotion that hydrates delicate skin all '
        'day long.',
  ),
  Product(
    id: 'baby-cereal',
    name: 'Baby Cereal',
    unit: '300 g',
    emoji: '🥣',
    price: 980,
    tint: Color(0xFFF9EFDA),
    categoryId: 'baby',
    description:
        'Iron fortified cereal for growing babies, easily digestible '
        'and gentle on tiny tummies.',
  ),

  // Pet Care.
  Product(
    id: 'cat-food',
    name: 'Whiskas Cat Food',
    unit: '1.2 kg',
    emoji: '🐱',
    price: 940,
    tint: Color(0xFFE9EFF6),
    categoryId: 'pets',
    description:
        'Complete salmon flavoured dry food that keeps adult cats '
        'healthy and playful.',
  ),
  Product(
    id: 'dog-treats',
    name: 'Dog Treats',
    unit: '500 g',
    emoji: '🐶',
    price: 480,
    tint: Color(0xFFFAEBE2),
    categoryId: 'pets',
    description:
        'Crunchy training treats packed with protein and a flavour '
        'dogs adore.',
  ),
  Product(
    id: 'cat-litter',
    name: 'Cat Litter',
    unit: '5 kg',
    emoji: '🪣',
    price: 780,
    tint: Color(0xFFEAF0EA),
    categoryId: 'pets',
    description:
        'Fast clumping litter that locks away odour in seconds and '
        'scoops clean.',
  ),

  // Pharmacy.
  Product(
    id: 'panadol',
    name: 'Panadol Tablets',
    unit: 'strip',
    emoji: '💊',
    price: 60,
    tint: Color(0xFFE9F0FB),
    categoryId: 'pharma',
    description:
        'Paracetamol tablets for fever and mild pain relief, keep a '
        'strip ready at home.',
  ),
  Product(
    id: 'bandage',
    name: 'First Aid Bandage',
    unit: '20 pcs',
    emoji: '🩹',
    price: 110,
    tint: Color(0xFFFBEDEC),
    categoryId: 'pharma',
    description:
        'Sterile adhesive bandages for small cuts and everyday first '
        'aid.',
  ),
  Product(
    id: 'ors-sachets',
    name: 'ORS Sachets',
    unit: '10 pack',
    emoji: '💧',
    price: 50,
    tint: Color(0xFFEAF3EE),
    categoryId: 'pharma',
    description:
        'ORS sachets that quickly restore essential body fluids during '
        'hot summers.',
  ),
];

List<Product> productsForCategory(String categoryId) {
  return appProducts
      .where((product) => product.categoryId == categoryId)
      .toList();
}

int deliveryFeeFor(int itemsTotal) => itemsTotal >= 499 ? 0 : 29;
