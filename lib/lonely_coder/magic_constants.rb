class OKCupid
  module MagicNumbers
    # Used to build OKCupid search urls. These are the wacky values
    # that OKCupid expects.
    Ethnicity = {
      "asian" => 2,
      "black" => 8,
      "hispanic/latin" => 128,
      "indian" => 32,
      "middle eastern" => 4,
      "native american" => 16,
      "pacific islander" => 64,
      "white" => 256,
      "human" => 512
    }
    
    Gentation = {
      "girls who like guys" => 34,
      "guys who like girls" => 17,
      "girls who like girls" => 40,
      "guys who like guys" => 20,
      "both who like bi guys" => 54,
      "both who like bi girls" => 57,
      "straight girls only" => 2,
      "Straight guys only" => 1,
      "gay girls only" => 8,
      "gay guys only" => 4,
      "bi girls only" => 32,
      "bi guys only" => 16,
      "everybody" => 63
    }
    
    Filters = {
      # "account_status" => 29,
      "age" => 2,
      # "body_type" => 30,
      # "cats" => 17,
      # "children" => 18,
      # "community_award" => 31,
      # "diet" => 54,
      # "dogs" => 16,
      # "drinking" => 12,
      # "drugs" => 13,
      # "education" => 19,
      # "eligible" => 7,
      "ethnicity" => 9,
      "gentation" => 0,
      # "height" => 10,
      # "jobtype" => 15,
      # "join_date" => 6,
      # "languages" => 22,
      "last_login" => 5,
      # "looking_for" => 32,
      # "money" => 14,
      # "not_looking_for" => 34,
      # "num_ques_ans" => 33,
      # "personality" => 20,
      # "prof_score" => 28,
      "radius" => 3,
      "relationship_status" => 35,
      # "religion" => 8,
      "require_photo" => 1,
      # "sign" => 21,
      # "smoking" => 11,
      # "v_first_contact" => 27,
      # "v_looks" => 23,
      # "v_personality" => 25,
      
      # added by us
      'match_limit' => 'match_limit',
      'order_by' => 'order_by',
      'location' => 'location'
    }
    
    RelationshipStatus = {
      'single' => 2,
      'not single' => 12,
      'any' => 0
    }
    
    OrderBy = {
      'match %' => 'MATCH',
      'friend %' => 'FRIEND',
      'enemy %' => 'ENEMY',
      'special blend' => 'SPECIAL_BLEND',
      'join' => 'JOIN',
      'last login' => 'LOGIN'
    }
    
    LastLogin = {
      "now" => 3600,
      "last day" => 86400,
      "last week" => 604800,
      "last month" => 2678400,
      "last year" => 31536000,
      "last decade" => 315360000 
    }
  end
end