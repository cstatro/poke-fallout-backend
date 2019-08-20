class Wildmon < ApplicationRecord


    @@habitats = ["cave", "forest", "grassland", "mountain", "rare", "rough-terrain", "sea", "urban", "waters-edge"]



    def self.inhabitants_by_level(habitat, level)
        self.all.select{|wildmon| wildmon.habitat == habitat && wildmon.minimum_level <= level}
    end



   





end
