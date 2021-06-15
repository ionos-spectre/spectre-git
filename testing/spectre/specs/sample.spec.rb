describe 'Git' do
  it 'does some Git operations', tags: [:sample] do
    git 'example' do
      clone

      content = read_file('dummy.txt')

      content = content.to_i + 1

      write_file('dummy.txt', content)

      add('dummy.txt')
      commit('Dummy file updated')
      push

      cleanup
    end
  end
end
