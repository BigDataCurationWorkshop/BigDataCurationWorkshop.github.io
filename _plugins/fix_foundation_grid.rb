# Patches the Feeling Responsive theme's Foundation 5 Sass files before
# compilation. The theme wraps pure-Sass arithmetic in CSS calc(), which
# causes Ruby Sass 3.7.x to treat the result as an unresolvable CSS string
# rather than a Sass number — breaking any further arithmetic on the result.
#
# Two classes of fix are applied:
#
# 1. Specific literal patterns that appear inside Sass function calls:
#      percentage(calc($colNumber / $totalColumns))
#        -> percentage($colNumber / $totalColumns)
#    These need exact replacement because they are arguments to Sass functions
#    that expect a number, not a string.
#
# 2. General regex: any calc() whose argument contains a Sass $variable.
#    Ruby Sass does not interpolate $variables inside calc() — it emits them
#    literally, producing garbage CSS like `padding: 0 calc($topbar-height/3)`.
#    Stripping the calc() wrapper lets Sass evaluate the arithmetic normally.
#
# Using a Generator (priority :highest) ensures this runs before Jekyll
# converts any Sass files.
module Jekyll
  class FixFoundationSass < Generator
    safe true
    priority :highest

    # Exact string replacements (applied first, before the regex pass).
    EXACT_PATCHES = [
      # Foundation grid: percentage(calc(...)) -> percentage(...)
      [
        "percentage(calc($colNumber / $totalColumns))",
        "percentage($colNumber / $totalColumns)"
      ],
      # rem-calc: calc(strip-unit arithmetic) used as a Sass number
      [
        "calc(strip-unit($value) / strip-unit($base-value) * 1rem)",
        "strip-unit($value) / strip-unit($base-value) * 1rem"
      ],
      # strip-unit via px division
      [
        "calc($value / 1px)",
        "$value / 1px"
      ],
      # block-grid percentage
      [
        "calc((100/$even) / 100)",
        "(100/$even) / 100"
      ],
    ].freeze

    def generate(site)
      theme = site.theme
      unless theme
        Jekyll.logger.warn "FixFoundationSass:", "No theme found, skipping patches"
        return
      end

      sass_dir = theme.sass_path
      unless Dir.exist?(sass_dir)
        Jekyll.logger.warn "FixFoundationSass:", "Theme sass_path not found: #{sass_dir}"
        return
      end

      Dir.glob(File.join(sass_dir, "**", "*.scss")).each do |path|
        content = File.read(path)
        patched = content.dup

        # Pass 1: exact string replacements
        EXACT_PATCHES.each do |broken, fixed|
          patched.gsub!(broken, fixed)
        end

        # Pass 2: general regex — strip calc() from any expression that
        # contains a Sass $variable. Ruby Sass does not evaluate $vars inside
        # calc(), so they must be bare Sass arithmetic instead.
        # Negative lookbehind (?<![-\w]) prevents matching rem-calc( or
        # any other identifier that ends in "calc".
        patched.gsub!(/(?<![-\w])calc\(([^)]*\$[^)]*)\)/, '\1')

        next if patched == content

        File.write(path, patched)
        Jekyll.logger.info "FixFoundationSass:", "Patched #{File.basename(path)}"
      end
    end
  end
end
