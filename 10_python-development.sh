#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - PYTHON DEVELOPMENT MODULE
# File: 10_python-development.sh
# =============================================================================
# This module provides comprehensive Python development tools including
# intelligent environment management, project setup, code quality analysis,
# package management, testing automation, and advanced development workflows.
# =============================================================================

# Module metadata
declare -r PYTHON_MODULE_VERSION="2.1.0"
declare -r PYTHON_MODULE_NAME="Python Development Environment"
declare -r PYTHON_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# Module initialization
echo -e "${BASHRC_CYAN}🐍 Loading Python Development Environment...${BASHRC_NC}"

# =============================================================================
# INTELLIGENT PYTHON ENVIRONMENT MANAGEMENT
# =============================================================================

# Advanced Python environment manager with intelligent automation
pyenv() {
    local usage="Usage: pyenv [COMMAND] [OPTIONS] [ARGS]
    
🐍 Intelligent Python Environment Manager
Commands:
    create      Create new virtual environment
    activate    Activate environment
    deactivate  Deactivate current environment
    list        List available environments
    remove      Remove environment
    info        Show environment information
    install     Install packages with intelligent suggestions
    upgrade     Upgrade packages
    freeze      Generate requirements.txt
    analyze     Analyze project dependencies
    clean       Clean unused packages
    clone       Clone environment
    compare     Compare environments
    
Options:
    -n, --name NAME         Environment name
    -p, --python VERSION    Python version (3.8, 3.9, 3.10, 3.11, 3.12)
    -r, --requirements FILE Requirements file to install
    -g, --global            Use global environment
    -f, --force             Force operation
    -v, --verbose           Verbose output
    -a, --auto              Auto-detect project requirements
    --conda                 Use conda instead of venv
    --poetry                Use poetry for dependency management
    -h, --help              Show this help
    
Examples:
    pyenv create myproject -p 3.11 -r requirements.txt
    pyenv activate myproject
    pyenv install requests pandas --auto
    pyenv analyze --security --performance
    pyenv compare env1 env2"

    local command="${1:-list}"
    [[ "$command" =~ ^(create|activate|deactivate|list|remove|info|install|upgrade|freeze|analyze|clean|clone|compare)$ ]] && shift || command="list"
    
    case "$command" in
        create)     pyenv_create "$@" ;;
        activate)   pyenv_activate "$@" ;;
        deactivate) pyenv_deactivate "$@" ;;
        list)       pyenv_list "$@" ;;
        remove)     pyenv_remove "$@" ;;
        info)       pyenv_info "$@" ;;
        install)    pyenv_install "$@" ;;
        upgrade)    pyenv_upgrade "$@" ;;
        freeze)     pyenv_freeze "$@" ;;
        analyze)    pyenv_analyze "$@" ;;
        clean)      pyenv_clean "$@" ;;
        clone)      pyenv_clone "$@" ;;
        compare)    pyenv_compare "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Create new Python environment
pyenv_create() {
    local env_name=""
    local python_version=""
    local requirements_file=""
    local use_conda=false
    local use_poetry=false
    local auto_detect=false
    local verbose=false
    local force=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)          env_name="$2"; shift 2 ;;
            -p|--python)        python_version="$2"; shift 2 ;;
            -r|--requirements)  requirements_file="$2"; shift 2 ;;
            --conda)            use_conda=true; shift ;;
            --poetry)           use_poetry=true; shift ;;
            -a|--auto)          auto_detect=true; shift ;;
            -v|--verbose)       verbose=true; shift ;;
            -f|--force)         force=true; shift ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  [[ -z "$env_name" ]] && env_name="$1" || requirements_file="$1"; shift ;;
        esac
    done
    
    [[ -z "$env_name" ]] && { echo "Environment name required"; return 1; }
    
    local python_dir="$HOME/.bash_python_environments"
    local env_dir="$python_dir/envs"
    local metadata_dir="$python_dir/metadata"
    
    mkdir -p "$env_dir" "$metadata_dir"
    
    echo -e "🐍 Creating Python environment: $env_name"
    
    # Check if environment already exists
    if [[ -d "$env_dir/$env_name" && "$force" == "false" ]]; then
        echo "❌ Environment '$env_name' already exists. Use --force to overwrite."
        return 1
    fi
    
    # Auto-detect project requirements if requested
    if [[ "$auto_detect" == "true" ]]; then
        requirements_file=$(detect_project_requirements ".")
        [[ -n "$requirements_file" ]] && echo -e "📋 Auto-detected requirements: $requirements_file"
    fi
    
    # Determine Python version
    if [[ -z "$python_version" ]]; then
        python_version=$(detect_optimal_python_version "$requirements_file")
        echo -e "🔍 Auto-selected Python version: $python_version"
    fi
    
    # Create environment based on tool preference
    if [[ "$use_conda" == "true" ]]; then
        create_conda_environment "$env_name" "$python_version" "$requirements_file" "$verbose"
    elif [[ "$use_poetry" == "true" ]]; then
        create_poetry_environment "$env_name" "$python_version" "$requirements_file" "$verbose"
    else
        create_venv_environment "$env_name" "$python_version" "$requirements_file" "$verbose"
    fi
    
    # Create environment metadata
    create_environment_metadata "$env_name" "$python_version" "$requirements_file"
    
    echo -e "✅ Environment '$env_name' created successfully!"
    echo -e "💡 Activate with: pyenv activate $env_name"
}

# Create venv environment
create_venv_environment() {
    local env_name="$1"
    local python_version="$2"
    local requirements_file="$3"
    local verbose="$4"
    
    local env_dir="$HOME/.bash_python_environments/envs/$env_name"
    
    # Find Python executable
    local python_cmd=$(find_python_executable "$python_version")
    [[ -z "$python_cmd" ]] && { echo "❌ Python $python_version not found"; return 1; }
    
    [[ "$verbose" == "true" ]] && echo -e "🔧 Using Python: $python_cmd"
    
    # Create virtual environment
    "$python_cmd" -m venv "$env_dir" || { echo "❌ Failed to create venv"; return 1; }
    
    # Activate and install packages
    source "$env_dir/bin/activate"
    
    # Upgrade pip
    [[ "$verbose" == "true" ]] && echo -e "📦 Upgrading pip..."
    pip install --upgrade pip >/dev/null 2>&1
    
    # Install requirements if provided
    if [[ -n "$requirements_file" && -f "$requirements_file" ]]; then
        [[ "$verbose" == "true" ]] && echo -e "📋 Installing requirements from $requirements_file..."
        pip install -r "$requirements_file"
    fi
    
    deactivate
}

# Create conda environment
create_conda_environment() {
    local env_name="$1"
    local python_version="$2"
    local requirements_file="$3"
    local verbose="$4"
    
    if ! command -v conda >/dev/null 2>&1; then
        echo "❌ Conda not found. Install Anaconda/Miniconda first."
        return 1
    fi
    
    [[ "$verbose" == "true" ]] && echo -e "🐍 Creating conda environment..."
    conda create -n "$env_name" python="$python_version" -y
    
    # Install requirements if provided
    if [[ -n "$requirements_file" && -f "$requirements_file" ]]; then
        [[ "$verbose" == "true" ]] && echo -e "📋 Installing requirements..."
        conda activate "$env_name"
        pip install -r "$requirements_file"
        conda deactivate
    fi
}

# Activate Python environment
pyenv_activate() {
    local env_name="$1"
    [[ -z "$env_name" ]] && { echo "Environment name required"; return 1; }
    
    local python_dir="$HOME/.bash_python_environments"
    local env_dir="$python_dir/envs/$env_name"
    local metadata_file="$python_dir/metadata/${env_name}.json"
    
    # Check if environment exists
    if [[ ! -d "$env_dir" ]]; then
        # Try conda environment
        if command -v conda >/dev/null 2>&1 && conda env list | grep -q "^$env_name "; then
            conda activate "$env_name"
            export PYTHON_VIRTUAL_ENV="$env_name"
            export PYTHON_ENV_TYPE="conda"
            echo -e "🐍 Activated conda environment: $env_name"
            return 0
        fi
        
        echo "❌ Environment '$env_name' not found"
        echo "💡 Available environments:"
        pyenv_list
        return 1
    fi
    
    # Activate venv environment
    source "$env_dir/bin/activate"
    export PYTHON_VIRTUAL_ENV="$env_name"
    export PYTHON_ENV_TYPE="venv"
    
    echo -e "🐍 Activated environment: $env_name"
    
    # Show environment info
    if [[ -f "$metadata_file" ]]; then
        local python_version=$(grep '"python_version"' "$metadata_file" | cut -d'"' -f4)
        local created_date=$(grep '"created"' "$metadata_file" | cut -d'"' -f4 | cut -dT -f1)
        echo -e "📋 Python $python_version | Created: $created_date"
    fi
    
    # Log activation for analytics
    log_environment_action "activate" "$env_name"
}

# Deactivate current environment
pyenv_deactivate() {
    if [[ -n "$PYTHON_VIRTUAL_ENV" ]]; then
        local env_name="$PYTHON_VIRTUAL_ENV"
        
        if [[ "$PYTHON_ENV_TYPE" == "conda" ]]; then
            conda deactivate
        else
            deactivate 2>/dev/null || true
        fi
        
        unset PYTHON_VIRTUAL_ENV PYTHON_ENV_TYPE
        echo -e "🔓 Deactivated environment: $env_name"
        
        # Log deactivation
        log_environment_action "deactivate" "$env_name"
    else
        echo "ℹ️  No active Python environment"
    fi
}

# List available environments
pyenv_list() {
    local python_dir="$HOME/.bash_python_environments"
    local env_dir="$python_dir/envs"
    local metadata_dir="$python_dir/metadata"
    
    echo -e "🐍 Available Python Environments"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    local found_envs=false
    
    # List venv environments
    if [[ -d "$env_dir" ]]; then
        for env_path in "$env_dir"/*; do
            [[ ! -d "$env_path" ]] && continue
            found_envs=true
            
            local env_name=$(basename "$env_path")
            local metadata_file="$metadata_dir/${env_name}.json"
            local is_active=""
            
            [[ "$PYTHON_VIRTUAL_ENV" == "$env_name" ]] && is_active=" ${BASHRC_GREEN}(active)${BASHRC_NC}"
            
            echo -e "📦 $env_name$is_active"
            
            if [[ -f "$metadata_file" ]]; then
                local python_version=$(grep '"python_version"' "$metadata_file" | cut -d'"' -f4)
                local created_date=$(grep '"created"' "$metadata_file" | cut -d'"' -f4 | cut -dT -f1)
                local package_count=$(grep '"package_count"' "$metadata_file" | cut -d':' -f2 | tr -d ' ,')
                
                echo -e "   🐍 Python $python_version | 📦 $package_count packages | 📅 $created_date"
            fi
            
            # Show disk usage
            local size=$(du -sh "$env_path" 2>/dev/null | cut -f1)
            echo -e "   💾 Size: $size"
            echo
        done
    fi
    
    # List conda environments
    if command -v conda >/dev/null 2>&1; then
        local conda_envs=$(conda env list | grep -v "^#" | tail -n +2)
        if [[ -n "$conda_envs" ]]; then
            found_envs=true
            echo -e "🐍 ${BASHRC_YELLOW}Conda Environments:${BASHRC_NC}"
            while read -r env_name path; do
                [[ -z "$env_name" ]] && continue
                local is_active=""
                [[ "$PYTHON_VIRTUAL_ENV" == "$env_name" ]] && is_active=" ${BASHRC_GREEN}(active)${BASHRC_NC}"
                echo -e "   🐍 $env_name$is_active"
            done <<< "$conda_envs"
            echo
        fi
    fi
    
    if [[ "$found_envs" == "false" ]]; then
        echo -e "📭 No Python environments found"
        echo -e "💡 Create one with: pyenv create myproject"
    fi
}

# =============================================================================
# INTELLIGENT PROJECT MANAGEMENT
# =============================================================================

# Advanced Python project manager
pyproject() {
    local usage="Usage: pyproject [COMMAND] [OPTIONS] [ARGS]
    
🚀 Intelligent Python Project Manager
Commands:
    init        Initialize new Python project
    template    Create project from template
    analyze     Analyze existing project
    setup       Set up development environment
    test        Run project tests
    lint        Code quality analysis
    format      Auto-format code
    docs        Generate documentation
    build       Build and package project
    deploy      Deploy project
    health      Check project health
    
Templates:
    basic       Basic Python package structure
    cli         Command-line application
    web-flask   Flask web application
    web-fastapi FastAPI web application
    web-django  Django web application
    ml          Machine learning project
    data        Data science project
    api         REST API service
    
Options:
    -n, --name NAME         Project name
    -t, --template TYPE     Project template
    -d, --directory DIR     Project directory
    -a, --author AUTHOR     Author name
    -e, --email EMAIL       Author email
    -l, --license LICENSE   License type (MIT, Apache, GPL)
    --git                   Initialize git repository
    --env                   Create virtual environment
    -v, --verbose           Verbose output
    -h, --help              Show this help
    
Examples:
    pyproject init myapp --template web-fastapi --git --env
    pyproject analyze . --security --performance
    pyproject test --coverage --report
    pyproject lint --fix --format"

    local command="${1:-init}"
    [[ "$command" =~ ^(init|template|analyze|setup|test|lint|format|docs|build|deploy|health)$ ]] && shift || command="init"
    
    case "$command" in
        init)       pyproject_init "$@" ;;
        template)   pyproject_template "$@" ;;
        analyze)    pyproject_analyze "$@" ;;
        setup)      pyproject_setup "$@" ;;
        test)       pyproject_test "$@" ;;
        lint)       pyproject_lint "$@" ;;
        format)     pyproject_format "$@" ;;
        docs)       pyproject_docs "$@" ;;
        build)      pyproject_build "$@" ;;
        deploy)     pyproject_deploy "$@" ;;
        health)     pyproject_health "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Initialize new Python project
pyproject_init() {
    local project_name=""
    local template="basic"
    local directory=""
    local author=""
    local email=""
    local license="MIT"
    local init_git=false
    local create_env=false
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)          project_name="$2"; shift 2 ;;
            -t|--template)      template="$2"; shift 2 ;;
            -d|--directory)     directory="$2"; shift 2 ;;
            -a|--author)        author="$2"; shift 2 ;;
            -e|--email)         email="$2"; shift 2 ;;
            -l|--license)       license="$2"; shift 2 ;;
            --git)              init_git=true; shift ;;
            --env)              create_env=true; shift ;;
            -v|--verbose)       verbose=true; shift ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  [[ -z "$project_name" ]] && project_name="$1"; shift ;;
        esac
    done
    
    [[ -z "$project_name" ]] && { echo "Project name required"; return 1; }
    
    # Set default directory
    [[ -z "$directory" ]] && directory="./$project_name"
    
    # Get author info from git config if not provided
    [[ -z "$author" ]] && author=$(git config user.name 2>/dev/null || echo "Your Name")
    [[ -z "$email" ]] && email=$(git config user.email 2>/dev/null || echo "your.email@example.com")
    
    echo -e "🚀 Initializing Python project: $project_name"
    echo -e "📁 Directory: $directory"
    echo -e "📋 Template: $template"
    echo -e "👤 Author: $author <$email>"
    echo -e "📄 License: $license"
    echo
    
    # Create project directory
    mkdir -p "$directory"
    cd "$directory" || { echo "❌ Failed to create directory"; return 1; }
    
    # Generate project structure based on template
    case "$template" in
        basic)      create_basic_project "$project_name" "$author" "$email" "$license" "$verbose" ;;
        cli)        create_cli_project "$project_name" "$author" "$email" "$license" "$verbose" ;;
        web-flask)  create_flask_project "$project_name" "$author" "$email" "$license" "$verbose" ;;
        web-fastapi) create_fastapi_project "$project_name" "$author" "$email" "$license" "$verbose" ;;
        web-django) create_django_project "$project_name" "$author" "$email" "$license" "$verbose" ;;
        ml)         create_ml_project "$project_name" "$author" "$email" "$license" "$verbose" ;;
        data)       create_data_project "$project_name" "$author" "$email" "$license" "$verbose" ;;
        api)        create_api_project "$project_name" "$author" "$email" "$license" "$verbose" ;;
        *)          echo "❌ Unknown template: $template"; return 1 ;;
    esac
    
    # Initialize git repository
    if [[ "$init_git" == "true" ]]; then
        [[ "$verbose" == "true" ]] && echo -e "🔧 Initializing git repository..."
        git init >/dev/null 2>&1
        git add . >/dev/null 2>&1
        git commit -m "Initial commit: $project_name project setup" >/dev/null 2>&1
        echo -e "✅ Git repository initialized"
    fi
    
    # Create virtual environment
    if [[ "$create_env" == "true" ]]; then
        [[ "$verbose" == "true" ]] && echo -e "🐍 Creating virtual environment..."
        pyenv create "$project_name" --auto >/dev/null 2>&1
        echo -e "✅ Virtual environment created"
        echo -e "💡 Activate with: pyenv activate $project_name"
    fi
    
    echo -e "\n🎉 Project '$project_name' created successfully!"
    echo -e "📁 Location: $(pwd)"
    
    # Show next steps
    echo -e "\n📋 ${BASHRC_YELLOW}Next Steps:${BASHRC_NC}"
    [[ "$create_env" == "false" ]] && echo -e "   1. pyenv create $project_name --auto"
    echo -e "   2. pyenv activate $project_name"
    echo -e "   3. pip install -r requirements.txt"
    echo -e "   4. pyproject test"
}

# Create basic Python project structure
create_basic_project() {
    local project_name="$1" author="$2" email="$3" license="$4" verbose="$5"
    
    [[ "$verbose" == "true" ]] && echo -e "📦 Creating basic project structure..."
    
    # Create directory structure
    mkdir -p "$project_name" tests docs
    
    # Create __init__.py
    echo "\"\"\"$project_name package.\"\"\"" > "$project_name/__init__.py"
    echo "__version__ = \"0.1.0\"" >> "$project_name/__init__.py"
    
    # Create main module
    cat > "$project_name/main.py" << EOF
"""Main module for $project_name."""


def main():
    """Main function."""
    print("Hello from $project_name!")


if __name__ == "__main__":
    main()
EOF
    
    # Create setup.py
    create_setup_py "$project_name" "$author" "$email" "$license"
    
    # Create requirements files
    create_requirements_files "basic"
    
    # Create configuration files
    create_config_files "$project_name"
    
    # Create README
    create_readme "$project_name" "$author" "basic"
    
    # Create tests
    create_basic_tests "$project_name"
}

# Create FastAPI project structure
create_fastapi_project() {
    local project_name="$1" author="$2" email="$3" license="$4" verbose="$5"
    
    [[ "$verbose" == "true" ]] && echo -e "🚀 Creating FastAPI project structure..."
    
    # Create directory structure
    mkdir -p "$project_name"/{api,core,db,models,schemas,crud,tests} static templates
    
    # Create main application
    cat > "$project_name/main.py" << EOF
"""FastAPI application for $project_name."""

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from .api import api_router
from .core.config import settings

app = FastAPI(
    title="$project_name",
    description="$project_name API",
    version="0.1.0",
)

# Set all CORS enabled origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="static"), name="static")
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/")
async def root():
    """Root endpoint."""
    return {"message": "Welcome to $project_name API"}


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy"}
EOF
    
    # Create API router
    mkdir -p "$project_name/api"
    cat > "$project_name/api/__init__.py" << EOF
"""API package."""

from fastapi import APIRouter

api_router = APIRouter()

from . import items  # noqa
EOF
    
    cat > "$project_name/api/items.py" << EOF
"""Items API endpoints."""

from typing import List
from fastapi import APIRouter, HTTPException
from ..schemas.item import Item, ItemCreate

router = APIRouter()


@router.get("/items/", response_model=List[Item])
async def read_items():
    """Get all items."""
    return []


@router.post("/items/", response_model=Item)
async def create_item(item: ItemCreate):
    """Create new item."""
    return Item(id=1, **item.dict())


@router.get("/items/{item_id}", response_model=Item)
async def read_item(item_id: int):
    """Get item by ID."""
    if item_id == 1:
        return Item(id=1, name="Sample Item", description="A sample item")
    raise HTTPException(status_code=404, detail="Item not found")
EOF
    
    # Create schemas
    cat > "$project_name/schemas/__init__.py" << 'EOF'
"""Schemas package."""
EOF
    
    cat > "$project_name/schemas/item.py" << EOF
"""Item schemas."""

from typing import Optional
from pydantic import BaseModel


class ItemBase(BaseModel):
    """Base item schema."""
    name: str
    description: Optional[str] = None


class ItemCreate(ItemBase):
    """Item creation schema."""
    pass


class Item(ItemBase):
    """Item schema."""
    id: int

    class Config:
        orm_mode = True
EOF
    
    # Create core configuration
    cat > "$project_name/core/__init__.py" << 'EOF'
"""Core package."""
EOF
    
    cat > "$project_name/core/config.py" << EOF
"""Configuration settings."""

from typing import Optional
from pydantic import BaseSettings


class Settings(BaseSettings):
    """Application settings."""
    
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "$project_name"
    
    # Database
    DATABASE_URL: Optional[str] = None
    
    # Security
    SECRET_KEY: str = "your-secret-key-here"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    class Config:
        env_file = ".env"


settings = Settings()
EOF
    
    # Update API router to include items
    cat >> "$project_name/api/__init__.py" << EOF

from .items import router as items_router
api_router.include_router(items_router, prefix="/items", tags=["items"])
EOF
    
    # Create requirements files
    create_requirements_files "fastapi"
    
    # Create configuration files
    create_config_files "$project_name"
    
    # Create README
    create_readme "$project_name" "$author" "fastapi"
    
    # Create tests
    create_fastapi_tests "$project_name"
    
    # Create Dockerfile
    create_dockerfile "fastapi"
}

# Create Machine Learning project structure
create_ml_project() {
    local project_name="$1" author="$2" email="$3" license="$4" verbose="$5"
    
    [[ "$verbose" == "true" ]] && echo -e "🤖 Creating ML project structure..."
    
    # Create directory structure
    mkdir -p "$project_name"/{data,models,notebooks,src,scripts,config,tests} data/{raw,processed,external} models/{trained,checkpoints}
    
    # Create main module
    cat > "$project_name/src/__init__.py" << 'EOF'
"""Source package."""
EOF
    
    cat > "$project_name/src/data_loader.py" << EOF
"""Data loading utilities."""

import pandas as pd
from pathlib import Path


class DataLoader:
    """Data loader class."""
    
    def __init__(self, data_dir: str = "data"):
        self.data_dir = Path(data_dir)
    
    def load_raw_data(self, filename: str) -> pd.DataFrame:
        """Load raw data from file."""
        filepath = self.data_dir / "raw" / filename
        
        if filepath.suffix == ".csv":
            return pd.read_csv(filepath)
        elif filepath.suffix == ".json":
            return pd.read_json(filepath)
        else:
            raise ValueError(f"Unsupported file format: {filepath.suffix}")
    
    def save_processed_data(self, df: pd.DataFrame, filename: str):
        """Save processed data."""
        filepath = self.data_dir / "processed" / filename
        df.to_csv(filepath, index=False)
EOF
    
    cat > "$project_name/src/model.py" << EOF
"""Model definitions."""

from sklearn.base import BaseEstimator, TransformerMixin
import joblib
from pathlib import Path


class MLModel:
    """Machine Learning model wrapper."""
    
    def __init__(self, model_path: str = None):
        self.model = None
        self.model_path = model_path
    
    def train(self, X, y):
        """Train the model."""
        # Implement your training logic here
        pass
    
    def predict(self, X):
        """Make predictions."""
        if self.model is None:
            raise ValueError("Model not trained. Call train() first.")
        return self.model.predict(X)
    
    def save(self, filepath: str):
        """Save trained model."""
        joblib.dump(self.model, filepath)
    
    def load(self, filepath: str):
        """Load trained model."""
        self.model = joblib.load(filepath)
EOF
    
    # Create Jupyter notebook template
    cat > "$project_name/notebooks/01_data_exploration.ipynb" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Data Exploration\n",
    "\n",
    "This notebook contains initial data exploration and analysis."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\n",
    "import numpy as np\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "\n",
    "# Set style\n",
    "plt.style.use('seaborn')\n",
    "sns.set_palette('husl')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Load data\n",
    "# df = pd.read_csv('../data/raw/your_data.csv')\n",
    "# df.head()"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.9.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
    
    # Create requirements files
    create_requirements_files "ml"
    
    # Create configuration files
    create_config_files "$project_name"
    
    # Create README
    create_readme "$project_name" "$author" "ml"
    
    # Create tests
    create_ml_tests "$project_name"
}

# =============================================================================
# CODE QUALITY AND ANALYSIS TOOLS
# =============================================================================

# Advanced code quality analysis
pyproject_lint() {
    local fix_issues=false
    local format_code=false
    local type_check=false
    local security_check=false
    local complexity_check=false
    local output_format="text"
    local config_file=""
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fix)              fix_issues=true; shift ;;
            --format)           format_code=true; shift ;;
            --type-check)       type_check=true; shift ;;
            --security)         security_check=true; shift ;;
            --complexity)       complexity_check=true; shift ;;
            -f|--output-format) output_format="$2"; shift 2 ;;
            -c|--config)        config_file="$2"; shift 2 ;;
            -v|--verbose)       verbose=true; shift ;;
            *)                  shift ;;
        esac
    done
    
    echo -e "🔍 Code Quality Analysis"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    local issues_found=0
    local tools_used=()
    
    # Pylint analysis
    if command -v pylint >/dev/null 2>&1; then
        echo -e "🔧 ${BASHRC_YELLOW}Running Pylint Analysis...${BASHRC_NC}"
        tools_used+=("pylint")
        
        local pylint_cmd="pylint"
        [[ -n "$config_file" ]] && pylint_cmd="$pylint_cmd --rcfile=$config_file"
        
        if [[ "$verbose" == "true" ]]; then
            $pylint_cmd . --reports=y
        else
            local pylint_output=$($pylint_cmd . --reports=n 2>/dev/null || true)
            local pylint_score=$(echo "$pylint_output" | grep "Your code has been rated" | awk '{print $7}' | cut -d'/' -f1)
            
            if [[ -n "$pylint_score" ]]; then
                echo -e "   📊 Pylint Score: $pylint_score/10"
                local issue_count=$(echo "$pylint_output" | grep -E "^[C|R|W|E]:" | wc -l)
                [[ $issue_count -gt 0 ]] && {
                    echo -e "   ⚠️  Issues Found: $issue_count"
                    issues_found=$((issues_found + issue_count))
                }
            fi
        fi
        echo
    fi
    
    # Flake8 analysis
    if command -v flake8 >/dev/null 2>&1; then
        echo -e "📏 ${BASHRC_YELLOW}Running Flake8 Analysis...${BASHRC_NC}"
        tools_used+=("flake8")
        
        local flake8_output=$(flake8 . 2>/dev/null || true)
        if [[ -n "$flake8_output" ]]; then
            local flake8_count=$(echo "$flake8_output" | wc -l)
            echo -e "   ⚠️  Style Issues: $flake8_count"
            issues_found=$((issues_found + flake8_count))
            
            [[ "$verbose" == "true" ]] && echo "$flake8_output" | head -20
        else
            echo -e "   ✅ No style issues found"
        fi
        echo
    fi
    
    # MyPy type checking
    if [[ "$type_check" == "true" ]] && command -v mypy >/dev/null 2>&1; then
        echo -e "🔍 ${BASHRC_YELLOW}Running MyPy Type Check...${BASHRC_NC}"
        tools_used+=("mypy")
        
        local mypy_output=$(mypy . 2>/dev/null || true)
        if [[ -n "$mypy_output" ]]; then
            local mypy_count=$(echo "$mypy_output" | grep -c "error:" || echo "0")
            echo -e "   ⚠️  Type Errors: $mypy_count"
            issues_found=$((issues_found + mypy_count))
            
            [[ "$verbose" == "true" ]] && echo "$mypy_output" | head -20
        else
            echo -e "   ✅ No type errors found"
        fi
        echo
    fi
    
    # Security check with bandit
    if [[ "$security_check" == "true" ]] && command -v bandit >/dev/null 2>&1; then
        echo -e "🔒 ${BASHRC_YELLOW}Running Security Analysis...${BASHRC_NC}"
        tools_used+=("bandit")
        
        local bandit_output=$(bandit -r . -f json 2>/dev/null || true)
        if [[ -n "$bandit_output" ]]; then
            local high_issues=$(echo "$bandit_output" | jq '.metrics._totals.SEVERITY.HIGH // 0' 2>/dev/null || echo "0")
            local medium_issues=$(echo "$bandit_output" | jq '.metrics._totals.SEVERITY.MEDIUM // 0' 2>/dev/null || echo "0")
            local low_issues=$(echo "$bandit_output" | jq '.metrics._totals.SEVERITY.LOW // 0' 2>/dev/null || echo "0")
            
            echo -e "   🔴 High: $high_issues | 🟡 Medium: $medium_issues | 🟢 Low: $low_issues"
            issues_found=$((issues_found + high_issues + medium_issues))
        fi
        echo
    fi
    
    # Format code if requested
    if [[ "$format_code" == "true" ]]; then
        run_code_formatters "$fix_issues" "$verbose"
    fi
    
    # Generate summary
    echo -e "📊 ${BASHRC_PURPLE}Analysis Summary${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..30})${BASHRC_NC}"
    echo -e "🔧 Tools Used: ${tools_used[*]}"
    echo -e "⚠️  Total Issues: $issues_found"
    
    if [[ $issues_found -eq 0 ]]; then
        echo -e "✅ ${BASHRC_GREEN}Code quality looks good!${BASHRC_NC}"
    elif [[ $issues_found -lt 10 ]]; then
        echo -e "🟡 ${BASHRC_YELLOW}Minor issues found${BASHRC_NC}"
    else
        echo -e "🔴 ${BASHRC_RED}Multiple issues need attention${BASHRC_NC}"
    fi
    
    # Suggest improvements
    suggest_quality_improvements "$issues_found" "${tools_used[@]}"
}

# Run code formatters
run_code_formatters() {
    local fix_issues="$1"
    local verbose="$2"
    
    echo -e "🎨 ${BASHRC_YELLOW}Code Formatting${BASHRC_NC}"
    
    # Black formatter
    if command -v black >/dev/null 2>&1; then
        if [[ "$fix_issues" == "true" ]]; then
            echo -e "   🔧 Running Black formatter..."
            black . --quiet 2>/dev/null && echo -e "   ✅ Code formatted with Black"
        else
            local black_output=$(black . --check --quiet 2>&1 || true)
            [[ -n "$black_output" ]] && echo -e "   📝 Black would reformat files" || echo -e "   ✅ Code already formatted"
        fi
    fi
    
    # isort for imports
    if command -v isort >/dev/null 2>&1; then
        if [[ "$fix_issues" == "true" ]]; then
            echo -e "   🔧 Running isort..."
            isort . --quiet 2>/dev/null && echo -e "   ✅ Imports sorted with isort"
        else
            local isort_output=$(isort . --check-only --quiet 2>&1 || true)
            [[ $? -ne 0 ]] && echo -e "   📝 isort would sort imports" || echo -e "   ✅ Imports already sorted"
        fi
    fi
    
    echo
}

# =============================================================================
# TESTING AUTOMATION
# =============================================================================

# Advanced testing system
pyproject_test() {
    local test_type="all"
    local coverage=false
    local report=false
    local parallel=false
    local verbose=false
    local output_dir="test_reports"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --unit)             test_type="unit"; shift ;;
            --integration)      test_type="integration"; shift ;;
            --coverage)         coverage=true; shift ;;
            --report)           report=true; shift ;;
            --parallel)         parallel=true; shift ;;
            -v|--verbose)       verbose=true; shift ;;
            -o|--output)        output_dir="$2"; shift 2 ;;
            *)                  shift ;;
        esac
    done
    
    echo -e "🧪 Running Python Tests"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    # Check if pytest is available
    if ! command -v pytest >/dev/null 2>&1; then
        echo -e "❌ pytest not found. Installing..."
        pip install pytest pytest-cov pytest-html >/dev/null 2>&1
    fi
    
    # Prepare test command
    local pytest_cmd="pytest"
    local test_args=()
    
    # Test discovery
    case "$test_type" in
        unit)           test_args+=("tests/unit" "-k" "test_") ;;
        integration)    test_args+=("tests/integration" "-k" "test_") ;;
        *)              test_args+=("tests/") ;;
    esac
    
    # Add options
    [[ "$verbose" == "true" ]] && test_args+=("-v")
    [[ "$parallel" == "true" ]] && test_args+=("-n" "auto")
    
    # Coverage options
    if [[ "$coverage" == "true" ]]; then
        test_args+=("--cov=." "--cov-report=term-missing")
        [[ "$report" == "true" ]] && test_args+=("--cov-report=html:$output_dir/coverage")
    fi
    
    # HTML report
    [[ "$report" == "true" ]] && test_args+=("--html=$output_dir/report.html" "--self-contained-html")
    
    # Create output directory
    [[ "$report" == "true" ]] && mkdir -p "$output_dir"
    
    # Run tests
    echo -e "🏃 ${BASHRC_CYAN}Executing tests...${BASHRC_NC}"
    local start_time=$(date +%s)
    
    local test_output
    if test_output=$($pytest_cmd "${test_args[@]}" 2>&1); then
        local test_status="✅ PASSED"
        local status_color="$BASHRC_GREEN"
    else
        local test_status="❌ FAILED"
        local status_color="$BASHRC_RED"
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Parse test results
    local tests_run=$(echo "$test_output" | grep -o "[0-9]* passed\|[0-9]* failed\|[0-9]* error" | head -1 | awk '{print $1}')
    local tests_passed=$(echo "$test_output" | grep -o "[0-9]* passed" | awk '{print $1}' || echo "0")
    local tests_failed=$(echo "$test_output" | grep -o "[0-9]* failed" | awk '{print $1}' || echo "0")
    
    # Coverage percentage
    local coverage_percent=""
    if [[ "$coverage" == "true" ]]; then
        coverage_percent=$(echo "$test_output" | grep "TOTAL" | awk '{print $NF}' | tr -d '%')
    fi
    
    # Display results
    echo -e "\n📊 ${BASHRC_PURPLE}Test Results${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..30})${BASHRC_NC}"
    echo -e "🏆 Status: ${status_color}$test_status${BASHRC_NC}"
    echo -e "🧪 Tests Run: ${tests_run:-0}"
    echo -e "✅ Passed: ${tests_passed}"
    echo -e "❌ Failed: ${tests_failed}"
    echo -e "⏱️  Duration: ${duration}s"
    
    [[ -n "$coverage_percent" ]] && echo -e "📊 Coverage: ${coverage_percent}%"
    
    # Show reports location
    if [[ "$report" == "true" ]]; then
        echo -e "\n📄 ${BASHRC_CYAN}Reports Generated:${BASHRC_NC}"
        echo -e "   🌐 HTML Report: $output_dir/report.html"
        [[ "$coverage" == "true" ]] && echo -e "   📊 Coverage Report: $output_dir/coverage/index.html"
    fi
    
    # Show verbose output if requested
    [[ "$verbose" == "true" ]] && {
        echo -e "\n📝 ${BASHRC_YELLOW}Detailed Output:${BASHRC_NC}"
        echo "$test_output"
    }
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Detect project requirements
detect_project_requirements() {
    local project_dir="$1"
    
    local requirements_files=(
        "requirements.txt"
        "requirements.in"
        "pyproject.toml"
        "Pipfile"
        "environment.yml"
        "setup.py"
    )
    
    for req_file in "${requirements_files[@]}"; do
        [[ -f "$project_dir/$req_file" ]] && { echo "$req_file"; return; }
    done
}

# Detect optimal Python version
detect_optimal_python_version() {
    local requirements_file="$1"
    
    # Check for version constraints in requirements
    if [[ -n "$requirements_file" && -f "$requirements_file" ]]; then
        # Parse python_requires from setup.py or pyproject.toml
        if [[ "$requirements_file" == "setup.py" ]]; then
            local python_req=$(grep "python_requires" "$requirements_file" | sed 's/.*python_requires.*=.*"\([^"]*\)".*/\1/')
            [[ -n "$python_req" ]] && echo "3.11" && return
        fi
    fi
    
    # Default to latest stable version
    echo "3.11"
}

# Find Python executable
find_python_executable() {
    local version="$1"
    
    local python_commands=(
        "python$version"
        "python3"
        "python"
    )
    
    for cmd in "${python_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            local found_version=$("$cmd" --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
            if [[ -z "$version" || "$found_version" == "$version" ]]; then
                echo "$cmd"
                return 0
            fi
        fi
    done
}

# Create requirements files
create_requirements_files() {
    local project_type="$1"
    
    case "$project_type" in
        basic)
            cat > requirements.txt << 'EOF'
# Production dependencies

EOF
            ;;
        fastapi)
            cat > requirements.txt << 'EOF'
# FastAPI Dependencies
fastapi>=0.104.0
uvicorn[standard]>=0.24.0
pydantic>=2.4.0
python-multipart>=0.0.6

# Database (optional)
# sqlalchemy>=2.0.0
# psycopg2-binary>=2.9.0

# Security (optional)
# python-jose[cryptography]>=3.3.0
# passlib[bcrypt]>=1.7.4
EOF
            ;;
        ml)
            cat > requirements.txt << 'EOF'
# Machine Learning Dependencies
numpy>=1.24.0
pandas>=2.0.0
scikit-learn>=1.3.0
matplotlib>=3.7.0
seaborn>=0.12.0
jupyter>=1.0.0
jupyterlab>=4.0.0

# Deep Learning (optional)
# torch>=2.0.0
# tensorflow>=2.13.0

# Data Processing
# polars>=0.19.0
# dask>=2023.9.0
EOF
            ;;
    esac
    
    # Development requirements
    cat > requirements-dev.txt << 'EOF'
# Development Dependencies
pytest>=7.4.0
pytest-cov>=4.1.0
pytest-html>=3.2.0
black>=23.9.0
isort>=5.12.0
flake8>=6.1.0
mypy>=1.5.0
bandit>=1.7.5
pre-commit>=3.4.0

# Documentation
sphinx>=7.2.0
sphinx-rtd-theme>=1.3.0

# Linting and Formatting
pylint>=2.17.0
autopep8>=2.0.0
EOF
}

# Create setup.py
create_setup_py() {
    local project_name="$1" author="$2" email="$3" license="$4"
    
    cat > setup.py << EOF
"""Setup configuration for $project_name."""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open("requirements.txt", "r", encoding="utf-8") as fh:
    requirements = [line.strip() for line in fh if line.strip() and not line.startswith("#")]

setup(
    name="$project_name",
    version="0.1.0",
    author="$author",
    author_email="$email",
    description="A Python project: $project_name",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/$author/$project_name",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: $license License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
    ],
    python_requires=">=3.8",
    install_requires=requirements,
    extras_require={
        "dev": [
            "pytest>=7.4.0",
            "black>=23.9.0",
            "isort>=5.12.0",
            "flake8>=6.1.0",
        ],
    },
    entry_points={
        "console_scripts": [
            "$project_name=$project_name.main:main",
        ],
    },
)
EOF
}

# Create configuration files
create_config_files() {
    local project_name="$1"
    
    # .gitignore
    cat > .gitignore << 'EOF'
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
test_reports/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
Pipfile.lock

# PEP 582
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# PyCharm
.idea/

# VS Code
.vscode/

# macOS
.DS_Store

# Windows
Thumbs.db
EOF
    
    # pyproject.toml
    cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$project_name"
version = "0.1.0"
description = "A Python project: $project_name"
readme = "README.md"
requires-python = ">=3.8"
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

[tool.black]
line-length = 88
target-version = ["py38", "py39", "py310", "py311", "py312"]
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88
known_first_party = ["$project_name"]

[tool.pytest.ini_options]
minversion = "6.0"
addopts = "-ra -q --strict-markers"
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]

[tool.coverage.run]
source = ["$project_name"]
omit = ["*/tests/*", "*/test_*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
]

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true
EOF
}

# Create README
create_readme() {
    local project_name="$1" author="$2" template="$3"
    
    cat > README.md << EOF
# $project_name

A Python project built with the Ultimate Bashrc Ecosystem.

## Description

${project_name} is a ${template} project created with intelligent project scaffolding.

## Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$author/$project_name.git
cd $project_name

# Create and activate virtual environment
pyenv create $project_name --auto
pyenv activate $project_name

# Install dependencies
pip install -r requirements.txt
\`\`\`

## Usage

\`\`\`bash
# Run the application
python -m $project_name

# Run tests
pyproject test --coverage

# Code quality checks
pyproject lint --fix --format
\`\`\`

## Development

\`\`\`bash
# Install development dependencies
pip install -r requirements-dev.txt

# Run tests with coverage
pytest --cov=$project_name --cov-report=html

# Format code
black .
isort .

# Type checking
mypy $project_name/
\`\`\`

## Project Structure

\`\`\`
$project_name/
├── $project_name/          # Main package
├── tests/                  # Test files
├── docs/                   # Documentation
├── requirements.txt        # Production dependencies
├── requirements-dev.txt    # Development dependencies
├── setup.py               # Package setup
├── pyproject.toml         # Project configuration
└── README.md              # This file
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and quality checks
5. Submit a pull request

## License

This project is licensed under the MIT License.
EOF
}

# Create basic tests
create_basic_tests() {
    local project_name="$1"
    
    mkdir -p tests
    
    cat > tests/__init__.py << 'EOF'
"""Test package."""
EOF
    
    cat > tests/test_main.py << EOF
"""Tests for main module."""

import pytest
from $project_name.main import main


def test_main():
    """Test main function."""
    # This is a placeholder test
    assert main() is None


def test_example():
    """Example test."""
    assert 1 + 1 == 2


@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 3),
    (3, 4),
])
def test_increment(input, expected):
    """Test increment function."""
    assert input + 1 == expected
EOF
}

# Create environment metadata
create_environment_metadata() {
    local env_name="$1" python_version="$2" requirements_file="$3"
    
    local metadata_dir="$HOME/.bash_python_environments/metadata"
    local metadata_file="$metadata_dir/${env_name}.json"
    
    local package_count=0
    [[ -n "$requirements_file" && -f "$requirements_file" ]] && package_count=$(grep -v "^#\|^$" "$requirements_file" | wc -l)
    
    cat > "$metadata_file" << EOF
{
  "name": "$env_name",
  "python_version": "$python_version",
  "created": "$(date -Iseconds)",
  "requirements_file": "$requirements_file",
  "package_count": $package_count,
  "last_activated": null,
  "activation_count": 0
}
EOF
}

# Log environment action
log_environment_action() {
    local action="$1" env_name="$2"
    
    local python_dir="$HOME/.bash_python_environments"
    local log_file="$python_dir/activity.log"
    
    mkdir -p "$python_dir"
    echo "$(date -Iseconds),$action,$env_name" >> "$log_file"
    
    # Update metadata if exists
    local metadata_file="$python_dir/metadata/${env_name}.json"
    if [[ -f "$metadata_file" && "$action" == "activate" ]]; then
        # Update last activated and increment count (simplified)
        sed -i "s/\"last_activated\": null/\"last_activated\": \"$(date -Iseconds)\"/" "$metadata_file"
    fi
}

# =============================================================================
# MODULE INITIALIZATION AND ALIASES
# =============================================================================

# Initialize Python development system
initialize_python_system() {
    local python_dir="$HOME/.bash_python_environments"
    mkdir -p "$python_dir"/{envs,metadata,templates,cache}
    
    # Check for Python tools and show installation suggestions
    check_python_tools
    
    # Set up Python-specific environment variables
    export PYTHONDONTWRITEBYTECODE=1
    export PYTHONUNBUFFERED=1
    
    echo -e "🐍 Python development system initialized"
}

# Check for Python tools availability
check_python_tools() {
    local missing_tools=()
    local recommended_tools=("pip" "black" "isort" "flake8" "pytest" "mypy")
    
    for tool in "${recommended_tools[@]}"; do
        command -v "$tool" >/dev/null 2>&1 || missing_tools+=("$tool")
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "💡 ${BASHRC_YELLOW}Recommended Python tools:${BASHRC_NC} ${missing_tools[*]}"
        echo -e "   Install with: pip install ${missing_tools[*]}"
    fi
}

# Create convenient aliases
alias py='python'
alias py3='python3'
alias venv='pyenv'
alias proj='pyproject'

# Python development aliases
alias pyclean='find . -type f -name "*.py[co]" -delete -o -type d -name "__pycache__" -delete'
alias pyserver='python -m http.server'
alias pypath='python -c "import sys; print(\"\n\".join(sys.path))"'
alias pyversion='python --version'

# Quick testing aliases
alias pytest-cov='pytest --cov=. --cov-report=html'
alias pytest-watch='pytest-watch'

# Export functions
export -f pyenv pyenv_create pyenv_activate pyenv_deactivate pyenv_list pyenv_remove pyenv_info
export -f pyenv_install pyenv_upgrade pyenv_freeze pyenv_analyze pyenv_clean
export -f pyproject pyproject_init pyproject_analyze pyproject_test pyproject_lint pyproject_format
export -f create_venv_environment create_conda_environment create_basic_project create_fastapi_project
export -f create_ml_project create_requirements_files create_setup_py create_config_files
export -f create_readme create_basic_tests create_environment_metadata
export -f detect_project_requirements detect_optimal_python_version find_python_executable
export -f log_environment_action run_code_formatters

# Initialize the system
initialize_python_system

echo -e "${BASHRC_GREEN}✅ Python Development Module Loaded${BASHRC_NC}"
echo -e "${BASHRC_PURPLE}🐍 Python Development v$PYTHON_MODULE_VERSION Ready!${BASHRC_NC}"
echo -e "${BASHRC_CYAN}💡 Try: 'pyenv create myproject -p 3.11 --auto', 'pyproject init webapp --template fastapi --git --env'${BASHRC_NC}"
