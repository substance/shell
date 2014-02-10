include Rake::DSL

module Git

  private
  class GitClone

    attr_reader :_repository, :_path, :_depth

    def initialize(repo)
      @_repository = repo
      @_path = nil
      @_depth = 0
      @_branch = nil
    end

    def repository(repo)
      @_repository = repo
    end

    def path(_path)
      @_path = _path
    end

    def depth(depth)
      @_depth = depth
    end

    def branch(branch)
      @_branch = branch
    end

    def run()
      cmd = ['git', 'clone']
      if @_depth > 0
        cmd += ['--depth', @_depth]
      end
      if @_branch != nil
        cmd += ['-b', @_branch]
      end
      cmd += [@_repository, @_path]
      cmd = cmd.join(' ')

      sh cmd
    end
  end

  public
  def self.clone(repo, &block)
    gitClone = GitClone.new(repo)
    gitClone.instance_eval(&block)

    file gitClone._path do |p|
      gitClone.run()
    end
  end

end
