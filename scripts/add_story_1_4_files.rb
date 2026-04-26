#!/usr/bin/env ruby
# Ajoute les fichiers Story 1.4 au .xcodeproj sans toucher au reste.
# Usage : ruby scripts/add_story_1_4_files.rb (depuis CoachingSage/)
require 'xcodeproj'

project_path = 'CoachingSage.xcodeproj'
project = Xcodeproj::Project.open(project_path)

main_target = project.targets.find { |t| t.name == 'CoachingSage' }
tests_target = project.targets.find { |t| t.name == 'CoachingSageTests' }
raise "CoachingSage target not found" unless main_target
raise "CoachingSageTests target not found" unless tests_target

# Trouve ou crée un groupe en suivant un chemin de path components depuis main_group.
def find_or_create_group(parent, components)
  components.each do |name|
    child = parent.children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && (c.name == name || c.path == name) }
    if child.nil?
      child = parent.new_group(name, name)
    end
    parent = child
  end
  parent
end

def add_swift_file(project, group, target, file_path, label)
  abs = File.join(File.dirname(project.path), file_path)
  raise "File missing: #{abs}" unless File.exist?(abs)
  existing = group.files.find { |f| f.path == File.basename(file_path) }
  if existing
    puts "  - skip (déjà dans le groupe) : #{label}"
    return existing
  end
  ref = group.new_reference(File.basename(file_path))
  ref.last_known_file_type = 'sourcecode.swift'
  target.add_file_references([ref])
  puts "  + ajouté : #{label}"
  ref
end

main_group = project.main_group

# Fichiers app (target CoachingSage)
puts "=== Target CoachingSage ==="
mappings_app = [
  { components: ['Services'], path: 'Services/AccountService.swift' },
  { components: ['ViewModels'], path: 'ViewModels/AccountViewModel.swift' },
  { components: ['Views', 'Screens'], path: 'Views/Screens/DeleteAccountView.swift' },
  { components: ['Utilities', 'ViewModifiers'], path: 'Utilities/ViewModifiers/DangerButtonStyle.swift' }
]
mappings_app.each do |m|
  group = find_or_create_group(main_group, m[:components])
  add_swift_file(project, group, main_target, m[:path], m[:path])
end

# Fichiers tests (target CoachingSageTests)
puts "=== Target CoachingSageTests ==="
mappings_tests = [
  { components: ['CoachingSageTests', 'Mocks'], path: 'CoachingSageTests/Mocks/MockAccountService.swift' },
  { components: ['CoachingSageTests', 'Services'], path: 'CoachingSageTests/Services/AccountServiceTests.swift' },
  { components: ['CoachingSageTests', 'ViewModels'], path: 'CoachingSageTests/ViewModels/AccountViewModelTests.swift' }
]
mappings_tests.each do |m|
  group = find_or_create_group(main_group, m[:components])
  add_swift_file(project, group, tests_target, m[:path], m[:path])
end

project.save
puts "Saved #{project_path}"
