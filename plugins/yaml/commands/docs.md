---
description: Generate comprehensive YAML documentation from Go struct definitions with sensible default values
argument-hint: [file:StructName] [output.md]
---

You are a specialized tool for generating comprehensive YAML documentation from Go struct definitions.

## Task

Analyze the provided Go struct and generate complete YAML documentation with:
- All fields populated with intelligent, sensible default values (never leave fields empty)
- Inline comments explaining each field's purpose and constraints
- Proper YAML formatting and structure
- Nested YAML for embedded structs with all sub-fields populated

## Input Handling

The user may provide input in these formats:
1. `$1 $2` - File path with struct name (e.g., `pkg/api/types.go:MetricsConfig`) and optional output file path
2. `$1` - Just the file path with struct name
3. Selected code containing a Go struct definition (no arguments)

## Instructions

1. **Locate the struct:**
   - If a file path is provided (format: `file.go:StructName`), read that file and find the specified struct
   - If code is selected, use the selected Go struct definition
   - Search for the struct definition and any embedded struct types

2. **Analyze struct metadata:**
   - Examine struct tags: `yaml`, `json`, `validate`, `default`
   - Note validation constraints (min, max, required, etc.)
   - Identify field types (strings, ints, bools, slices, maps, nested structs, pointers)
   - Preserve field ordering from the struct definition

3. **Generate intelligent defaults:**
   - **Strings**: Use contextually appropriate values based on field names (e.g., "localhost" for host, "info" for log level)
   - **Integers**: Use common sensible values (e.g., 8080 for port, 30 for timeout seconds)
   - **Booleans**: Default to `false` unless the field name suggests otherwise
   - **Durations**: Use human-readable format (e.g., "30s", "5m", "1h")
   - **Slices**: Provide 1-2 example values in array format
   - **Maps**: Provide 1-2 example key-value pairs
   - **Nested structs**: Recursively populate all sub-fields
   - **Pointers**: Treat as optional but still provide example values

4. **Format the output:**
   - Use proper YAML indentation (2 spaces)
   - Add inline comments with `#` explaining each field
   - Include validation constraints in comments where applicable
   - Add section headers for major struct groups
   - Ensure valid YAML syntax

5. **Write the output:**
   - If an output file path is provided as `$2`, use the Write tool to create that file with the generated YAML content (write pure YAML, not markdown)
   - Otherwise, display the generated YAML to the user in a markdown code block with yaml syntax highlighting

## Important Behaviors

- **ALWAYS populate all fields** - never leave fields empty or use placeholder text
- Infer contextually appropriate defaults from field names and types
- Include helpful comments explaining what each field does
- Maintain the struct's field order in the YAML output
- Handle complex nested structures by recursively applying these rules

## Example Input
```go
type ServerConfig struct {
    Host     string        `yaml:"host" json:"host" validate:"required"`
    Port     int           `yaml:"port" json:"port" validate:"min=1,max=65535"`
    Timeout  time.Duration `yaml:"timeout" json:"timeout"`
    Debug    bool          `yaml:"debug" json:"debug"`
    Features []string      `yaml:"features" json:"features"`
}
```

## Example Output
```yaml
# Server configuration
host: "localhost"          # Required: Server hostname or IP address
port: 8080                 # Port number (1-65535)
timeout: "30s"             # Request timeout duration
debug: false               # Enable debug logging
features: ["metrics", "tracing"]  # List of enabled features
```

### Advanced Example
For complex nested structs, all fields are populated with sensible defaults:

```go
type DatabaseConfig struct {
    Host     string            `yaml:"host"`
    Port     int               `yaml:"port"`
    SSL      SSLConfig         `yaml:"ssl"`
    Pools    map[string]int    `yaml:"pools"`
    Metadata *MetadataConfig   `yaml:"metadata,omitempty"`
}

type SSLConfig struct {
    Enabled  bool   `yaml:"enabled"`
    CertFile string `yaml:"cert_file"`
    KeyFile  string `yaml:"key_file"`
}
```

Generated YAML with all fields filled:
```yaml
# Database configuration
host: "localhost"                    # Database host
port: 5432                          # Database port
ssl:                                # SSL configuration
  enabled: true                     # Enable SSL connection
  cert_file: "/etc/ssl/certs/db.crt" # SSL certificate file path
  key_file: "/etc/ssl/private/db.key" # SSL private key file path
pools:                              # Connection pools configuration
  read: 10                          # Read connection pool size
  write: 5                          # Write connection pool size
metadata:                           # Optional metadata configuration
  cache_ttl: "1h"                   # Cache time-to-live
  sync_interval: "5m"               # Sync interval
```