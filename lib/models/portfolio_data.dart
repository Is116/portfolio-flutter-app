class Skill {
  final String name;
  final String category;

  const Skill({required this.name, required this.category});
}

class Project {
  final String title;
  final String description;
  final List<String> technologies;
  final int stars;
  final int forks;
  final String? demoUrl;

  const Project({
    required this.title,
    required this.description,
    required this.technologies,
    this.stars = 0,
    this.forks = 0,
    this.demoUrl,
  });
}

class Experience {
  final String role;
  final String company;
  final String companyUrl;
  final String period;
  final String type;
  final String description;
  final List<String> highlights;

  const Experience({
    required this.role,
    required this.company,
    required this.companyUrl,
    required this.period,
    required this.type,
    required this.description,
    required this.highlights,
  });
}

class Education {
  final String degree;
  final String institution;
  final String period;
  final String description;

  const Education({
    required this.degree,
    required this.institution,
    required this.period,
    required this.description,
  });
}

class PortfolioData {
  final String name;
  final String title;
  final String email;
  final String phone;
  final String website;
  final String linkedin;
  final String github;
  final String twitter;
  final String bio;
  final String company;
  final String location;
  final String tagline;
  final int yearsOfExperience;
  final int projectsCompleted;
  final List<Skill> skills;
  final List<Project> projects;
  final List<Experience> experiences;
  final List<Education> education;

  const PortfolioData({
    required this.name,
    required this.title,
    required this.email,
    required this.phone,
    required this.website,
    this.linkedin = '',
    this.github = '',
    this.twitter = '',
    this.bio = '',
    this.company = '',
    this.location = '',
    this.tagline = '',
    this.yearsOfExperience = 0,
    this.projectsCompleted = 0,
    this.skills = const [],
    this.projects = const [],
    this.experiences = const [],
    this.education = const [],
  });

  // Generate vCard format
  String toVCard() {
    return '''BEGIN:VCARD
VERSION:3.0
FN:$name
TITLE:$title
${company.isNotEmpty ? 'ORG:$company\n' : ''}TEL:$phone
EMAIL:$email
URL:$website
${linkedin.isNotEmpty ? 'X-SOCIALPROFILE;TYPE=linkedin:$linkedin\n' : ''}${github.isNotEmpty ? 'X-SOCIALPROFILE;TYPE=github:$github\n' : ''}${twitter.isNotEmpty ? 'X-SOCIALPROFILE;TYPE=twitter:$twitter\n' : ''}${location.isNotEmpty ? 'ADR:;;$location;;;;\n' : ''}${bio.isNotEmpty ? 'NOTE:$bio\n' : ''}END:VCARD''';
  }

  // Generate plain text format
  String toPlainText() {
    return '''$name
$title${company.isNotEmpty ? '\n$company' : ''}

📧 $email
📱 $phone
🌐 $website${linkedin.isNotEmpty ? '\n💼 $linkedin' : ''}${github.isNotEmpty ? '\n👨‍💻 $github' : ''}${twitter.isNotEmpty ? '\n🐦 $twitter' : ''}${location.isNotEmpty ? '\n📍 $location' : ''}

${bio.isNotEmpty ? bio : ''}''';
  }

  // Default portfolio data - CUSTOMIZE THIS WITH YOUR INFO
  static const PortfolioData defaultData = PortfolioData(
    name: 'Isuru Pathirathna',
    title: 'Full Stack Developer',
    tagline:
        'AI enthusiast building web & mobile apps. Breaking things to understand them, then building them better.',
    email: 'isuru2002@gmail.com',
    phone: '+358 41 367 1742',
    website: 'https://isurupathirathna.dev',
    linkedin: 'https://www.linkedin.com/in/isuru-abhiman-pathirathna-b3b9a4138',
    github: 'https://github.com/Is116',
    twitter: '',
    bio:
        '''Hey there! I'm Isuru Pathirathna, a web and mobile developer who believes code should be open, accessible, and maybe a little fun. I've been coding for over 3 years, diving into everything from React Native and Flutter apps to full-stack web platforms.

Here's my philosophy: if it works, break it intentionally. Why? Because understanding why something breaks teaches you way more than just watching it work. Then I build it back up, better and stronger.

I'm all about open-source development and writing reusable, clean code. Give me a new programming language and a couple of weeks, and I'll probably be building something with it.''',
    company: '',
    location: 'Finland',
    yearsOfExperience: 3,
    projectsCompleted: 50,
    skills: [
      Skill(name: 'React', category: 'Web Development'),
      Skill(name: 'Next.js', category: 'Web Development'),
      Skill(name: 'TypeScript', category: 'Web Development'),
      Skill(name: 'Tailwind CSS', category: 'Web Development'),
      Skill(name: 'Node.js', category: 'Web Development'),
      Skill(name: 'React Native', category: 'Mobile Development'),
      Skill(name: 'Expo', category: 'Mobile Development'),
      Skill(name: 'Firebase', category: 'Mobile Development'),
      Skill(name: 'Redux', category: 'Mobile Development'),
      Skill(name: 'Flutter', category: 'Mobile Development'),
      Skill(name: 'Laravel', category: 'Backend & AI Tools'),
      Skill(name: 'Express', category: 'Backend & AI Tools'),
      Skill(name: 'PostgreSQL', category: 'Backend & AI Tools'),
      Skill(name: 'MongoDB', category: 'Backend & AI Tools'),
      Skill(name: 'Gemini AI', category: 'Backend & AI Tools'),
    ],
    projects: [
      Project(
        title: 'React Native E-Commerce',
        description:
            'Full-featured mobile shopping app with cart management, payment integration, and real-time order tracking. Built with modern React Native architecture.',
        technologies: ['React Native', 'TypeScript', 'Redux', 'Firebase'],
        stars: 142,
        forks: 28,
      ),
      Project(
        title: 'Open Task Manager',
        description:
            'Collaborative task management platform with team workspaces, real-time sync, and Kanban boards. Fully open-source and self-hostable.',
        technologies: ['Next.js', 'Node.js', 'PostgreSQL', 'Socket.io'],
        stars: 89,
        forks: 15,
        demoUrl: 'https://demo.com',
      ),
      Project(
        title: 'DevTools CLI',
        description:
            'Command-line productivity toolkit for developers. Includes code generators, Git helpers, and deployment automation scripts.',
        technologies: ['Node.js', 'TypeScript', 'Commander', 'Chalk'],
        stars: 67,
        forks: 12,
      ),
    ],
    experiences: [
      Experience(
        role: 'Software Developer Trainee',
        company: 'CDB Bank',
        companyUrl: 'https://www.cdb.lk/',
        period: '2023 - Present',
        type: 'Training',
        description:
            'Training at Citizens Development Business Finance PLC, a leading financial institution focused on sustainable financing and digital banking solutions. Working with the CDB Self mobile app and digital banking platforms.',
        highlights: [
          'Developing features for CDB Self digital banking app',
          'Learning fintech solutions including payment processing and e-passbook',
          'Working with secure financial transaction systems and APIs',
        ],
      ),
      Experience(
        role: 'Full Stack Developer',
        company: 'Veesoft',
        companyUrl: 'https://www.veesoft.lk/',
        period: '2022 - 2023',
        type: 'Project-Based',
        description:
            'Developed comprehensive ERP solutions at Veesoft IT (Pvt) Ltd, specializing in JAPRA ERP system with integrated modules for POS, inventory, CRM, and business intelligence for retail and enterprise clients.',
        highlights: [
          'Built features for Smart POS & Inventory management system',
          'Developed mobile applications for sales representatives',
          'Created dashboard analytics and promotion modules using cloud technologies',
        ],
      ),
      Experience(
        role: 'Full Stack Developer',
        company: 'Codezela',
        companyUrl: 'https://codezela.com/',
        period: '2022',
        type: 'Project-Based',
        description:
            'Developed professional web and mobile applications at Codezela Technologies, a UK-based software company serving 500+ global clients across healthcare, finance, e-commerce, and education sectors with cutting-edge digital solutions.',
        highlights: [
          'Built e-commerce platforms and CMS solutions using Next.js and React',
          'Developed AI-powered features and mobile applications for diverse industries',
          'Implemented responsive designs with Tailwind CSS and modern frameworks',
        ],
      ),
    ],
    education: [
      Education(
        degree: 'Bachelor of Science in Computer Science',
        institution: 'University of Plymouth',
        period: '2019 - 2022',
        description:
            'Studied software engineering, web development, and computer science fundamentals with focus on modern development practices.',
      ),
    ],
  );
}
